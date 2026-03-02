//
//  RepositoriesViewModel.swift
//  Sporty Test
//
//  Created by Victor Marcel on 25/02/26.
//

import Foundation
import GitHubAPI

protocol RepositoriesViewModelDelegate: AnyObject {
    
    func onStateUpdate(_ state: RepositoriesScreenState)
    func onPullToRefreshError()
}

@MainActor
class RepositoriesViewModel {
    
    // MARK: - CONSTANTS
    
    enum Constants {
        static let defaultOrganizationName = "swiftlang"
    }
    
    // MARK: - PRIVATE PROPERTIES

    private let service: RepositoryServiceProtocol
    
    // MARK: - INTERNAL PROPERTIES
    
    private(set) var repositories: [GitHubMinimalRepository] = []
    private(set) var currentOrganizationName: String = .empty
    private(set) var state: RepositoriesScreenState? {
        didSet {
            guard let state else { return }
            delegate?.onStateUpdate(state)
        }
    }
    weak var delegate: RepositoriesViewModelDelegate?
    var numberOfRowsInSection: Int {
        state == .loading ? .zero : repositories.count
    }
    
    // MARK: - INITIALIZERS
    
    init(service: RepositoryServiceProtocol) {
        self.service = service
    }
    
    // MARK: - INTERNAL METHODS
    
    func onViewDidLoad() {
        fetchRepositories(by: Constants.defaultOrganizationName , fetchEvent: .viewDidLoad)
    }
    
    func didPullToRefresh() {
        fetchRepositories(by: currentOrganizationName, fetchEvent: .pullToRefresh)
    }
    
    func onSearchTap(_ text: String) {
        fetchRepositories(by: text.trimmingCharacters(in: .whitespaces), fetchEvent: .searchButton)
    }
    
    // MARK: - PRIVATE METHODS
    
    private func fetchRepositories(by organizationName: String, fetchEvent: RepositoriesScreenFetchEvent) {
        guard isValidOrganizationName(organizationName) || fetchEvent == .pullToRefresh else {
            return
        }
        
        Task {
            await performRepositoriesRequest(organizationName: organizationName, triggeredBy: fetchEvent)
        }
    }
    
    private func isValidOrganizationName(_ name: String) -> Bool {
        !name.isEmpty && name != currentOrganizationName
    }
    
    private func performRepositoriesRequest(
        organizationName: String,
        triggeredBy event: RepositoriesScreenFetchEvent
    ) async {
        state = event.loadingState
        do {
            repositories = try await service.fetchRepositories(for: organizationName)
            currentOrganizationName = organizationName
            state = .success
        } catch {
            handle(error: error, event: event)
        }
    }
    
    private func handle(error: Error, event: RepositoriesScreenFetchEvent) {
        guard event != .pullToRefresh else {
            delegate?.onPullToRefreshError()
            return
        }
        
        cleanCurrentOrganizationResult()
        state = buildState(by: error)
    }
    
    private func cleanCurrentOrganizationResult() {
        repositories = []
        currentOrganizationName = .empty
    }
    
    private func buildState(by error: Error) -> RepositoriesScreenState {
        guard let githubErrorState = error as? GitHubAPIError else {
            return .error(.invalidResponse)
        }
        
        return .error(githubErrorState)
    }
}
