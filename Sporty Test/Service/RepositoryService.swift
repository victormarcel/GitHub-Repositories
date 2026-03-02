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

    private var gitHubAPI: GitHubAPI
    private let mockLiveServer: MockLiveServer
    private let keychainManager: KeychainManagerProtocol

    // MARK: - INITIALIZERS

    init(gitHubAPI: GitHubAPI, mockLiveServer: MockLiveServer, keychainManager: KeychainManagerProtocol) {
        self.gitHubAPI = gitHubAPI
        self.mockLiveServer = mockLiveServer
        self.keychainManager = keychainManager
    }

    // MARK: - INTERNAL METHODS

    func fetchRepositories(for organization: String) async throws -> [GitHubMinimalRepository] {
        updateApiKeyInServiceApi()
        return try await gitHubAPI.repositoriesForOrganisation(organization)
    }
    
    // MARK: - PRIVATE METHODS
    
    private func updateApiKeyInServiceApi() {
        let apiKey = try? keychainManager.retrieve(for: .apiKey)
        gitHubAPI.setAuthorizationToken(apiKey)
    }
}
