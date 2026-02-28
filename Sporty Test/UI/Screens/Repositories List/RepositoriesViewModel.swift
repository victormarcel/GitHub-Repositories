//
//  RepositoriesViewModel.swift
//  Sporty Test
//
//  Created by Victor Marcel on 25/02/26.
//

import Foundation
import GitHubAPI
import MockLiveServer

protocol RepositoriesViewModelDelegate: AnyObject {
    
    func onStateUpdate(_ state: RepositoriesScreenState)
}

@MainActor
class RepositoriesViewModel {
    
    // MARK: - PRIVATE PROPERTIES
    
    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer
    
    // MARK: - INTERNAL PROPERTIES
    
    private(set) var repositories: [GitHubMinimalRepository] = []
    private(set) var state: RepositoriesScreenState? {
        didSet {
            guard let state else { return }
            delegate?.onStateUpdate(state)
        }
    }
    weak var delegate: RepositoriesViewModelDelegate?
    
    // MARK: - INITIALIZERS
    
    init(gitHubAPI: GitHubAPI, mockLiveServer: MockLiveServer) {
        self.gitHubAPI = gitHubAPI
        self.mockLiveServer = mockLiveServer
    }
    
    // MARK: - INTERNAL METHODS
    
    func onViewDidLoad() {
        Task {
            await loadRepositories(triggeredBy: .viewDidLoad)
        }
    }
    
    func didPullToRefresh() {
        Task {
            await loadRepositories(triggeredBy: .pullToRefresh)
        }
    }
    
    // MARK: - PRIVATE METHODS
    
    private func loadRepositories(triggeredBy event: RepositoriesScreenFetchEvent) async {
        state = event.loadingState
        do {
            try await Task.sleep(for: .seconds(1))
            repositories = try await gitHubAPI.repositoriesForOrganisation("swiftlang")
            state = .success
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
