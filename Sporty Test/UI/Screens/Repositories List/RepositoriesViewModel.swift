//
//  RepositoriesViewModel.swift
//  Sporty Test
//
//  Created by Victor Marcel on 25/02/26.
//

import Combine
import Foundation
import GitHubAPI
import MockLiveServer

protocol RepositoriesViewModelDelegate: AnyObject {
    
    func onStateUpdate(_ state: RepositoriesScreenState)
    func onRepositoryStarCountChange(_ repository: GitHubMinimalRepository, newStarCount: Int)
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
    private var starCountSubscribers: [Int: AnyCancellable] = [:]
    
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
    
    func didSetupCell(at index: Int) {
        guard let repository = repositories[safe: index] else {
            return
        }
        
        registerStarCountSubscriber(for: repository)
    }
    
    func didEndDisplayingCell(at index: Int) {
        guard let repository = repositories[safe: index] else {
            return
        }
        
        removeStarCountSubscriber(for: repository)
    }
    
    // MARK: - PRIVATE METHODS
    
    private func fetchRepositories(by organizationName: String, fetchEvent: RepositoriesScreenFetchEvent) {
        guard isValidOrganizationName(organizationName) || fetchEvent == .pullToRefresh else {
            return
        }
        
        Task {
            removeAllStarCountSubscribers()
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
    
    private func removeAllStarCountSubscribers() {
        starCountSubscribers.forEach {
            $0.value.cancel()
            starCountSubscribers[$0.key] = nil
        }
    }
        
    private func buildStarCountSubscriber(for repository: GitHubMinimalRepository) -> @Sendable (Int) -> Void {
        return { [weak self] newStarCount in
            Task {
                await self?.updateRepositoryStarCount(repository, newStarCount: newStarCount)
                await self?.delegate?.onRepositoryStarCountChange(repository, newStarCount: newStarCount)
            }
        }
    }
    
    private func updateRepositoryStarCount(_ repository: GitHubMinimalRepository, newStarCount: Int) {
        guard let index = repositories.firstIndex(where: { $0.id == repository.id }) else {
            return
        }
        
        repositories[index].stargazersCount = newStarCount
    }
    
    private func registerStarCountSubscriber(for repository: GitHubMinimalRepository) {
        Task {
            let builderSubscriber = buildStarCountSubscriber(for: repository)
            let cancellable = await service.registerStarCountSubscriber(for: repository, builderSubscriber)
            starCountSubscribers[repository.id] = cancellable
        }
    }
    
    private func removeStarCountSubscriber(for repository: GitHubMinimalRepository) {
        starCountSubscribers[repository.id]?.cancel()
    }
}
