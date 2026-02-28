//
//  RepositoriesScreenFetchEvent.swift
//  Sporty Test
//
//  Created by Victor Marcel on 28/02/26.
//

enum RepositoriesScreenFetchEvent: Equatable {
    case viewDidLoad
    case pullToRefresh
    
    var loadingState: RepositoriesScreenState {
        switch self {
        case .viewDidLoad:
            return .loading
        case .pullToRefresh:
            return .refreshing
        }
    }
}
