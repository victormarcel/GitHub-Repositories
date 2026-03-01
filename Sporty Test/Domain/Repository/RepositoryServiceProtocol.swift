//
//  RepositoryServiceProtocol.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import GitHubAPI

protocol RepositoryServiceProtocol {
    func fetchRepositories(for organization: String) async throws -> [GitHubMinimalRepository]
}
