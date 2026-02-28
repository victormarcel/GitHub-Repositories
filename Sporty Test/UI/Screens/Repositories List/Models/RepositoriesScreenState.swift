//
//  RepositoriesScreenState.swift
//  Sporty Test
//
//  Created by Victor Marcel on 28/02/26.
//

enum RepositoriesScreenState: Equatable {
    case loading
    case refreshing
    case success
    case error(String)
}
