//
//  RepositoriesScreenFetchEvent.swift
//  Sporty Test
//
//  Created by Victor Marcel on 28/02/26.
//

enum RepositoriesScreenFetchEvent: Equatable {
    
    case viewDidLoad
    case pullToRefresh
    case searchButton
    
    var loadingState: RepositoriesScreenState {
        switch self {
        case .viewDidLoad, .searchButton:
            return .loading
        case .pullToRefresh:
            return .refreshing
        }
    }
}
