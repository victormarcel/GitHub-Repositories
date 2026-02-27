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
    
    func onStateUpdate(_ state: RepositoriesViewModel.State)
}

@MainActor
class RepositoriesViewModel {
    
    enum State: Equatable {
        static func == (lhs: RepositoriesViewModel.State, rhs: RepositoriesViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.success, .success):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
        
        case loading
        case success
        case error(Error)
    }
    
    // MARK: - PRIVATE PROPERTIES
    
    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer
    
    // MARK: - INTERNAL PROPERTIES
    
    private(set) var repositories: [GitHubMinimalRepository] = []
    private(set) var state: State? {
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
            await loadRepositories()
        }
    }
    
    func loadRepositories() async {
        state = .loading
        do {
            repositories = try await gitHubAPI.repositoriesForOrganisation("swiftlang")
            state = .success
        } catch {
            state = .error(error)
        }
    }
}
