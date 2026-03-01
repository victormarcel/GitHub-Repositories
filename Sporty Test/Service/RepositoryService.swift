//
//  RepositoriesService.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import GitHubAPI
import MockLiveServer

final class RepositoryService: RepositoryServiceProtocol {

    // MARK: - PRIVATE PROPERTIES

    private let gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer

    // MARK: - INITIALIZERS

    init(gitHubAPI: GitHubAPI, mockLiveServer: MockLiveServer) {
        self.gitHubAPI = gitHubAPI
        self.mockLiveServer = mockLiveServer
    }

    // MARK: - INTERNAL METHODS

    func fetchRepositories(for organization: String) async throws -> [GitHubMinimalRepository] {
        try await gitHubAPI.repositoriesForOrganisation(organization)
    }
}
