//
//  RepositoryServiceProtocol.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import Combine
import GitHubAPI
import MockLiveServer

protocol RepositoryServiceProtocol {
    
    func fetchRepositories(for organization: String) async throws -> [GitHubMinimalRepository]
    
    func registerStarCountSubscriber(
        for repository: GitHubMinimalRepository,
        _ subscriber: @escaping MockLiveServer.Subscriber
    ) async -> AnyCancellable?
}
