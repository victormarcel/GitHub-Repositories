//
//  RepositoriesScreenState.swift
//  Sporty Test
//
//  Created by Victor Marcel on 28/02/26.
//

import GitHubAPI

enum RepositoriesScreenState: Equatable {
    
    case loading
    case refreshing
    case success
    case error(GitHubAPIError)
    
    static func == (lhs: RepositoriesScreenState, rhs: RepositoriesScreenState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.refreshing, .refreshing),
             (.success, .success):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
