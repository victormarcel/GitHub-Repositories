//
//  RepositoriesService.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import Combine
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
    
    func registerStarCountSubscriber(
        for repository: GitHubMinimalRepository,
        _ subscriber: @escaping MockLiveServer.Subscriber
    ) async -> AnyCancellable? {
        return try? await mockLiveServer.subscribeToRepo(
            repoId: repository.id,
            currentStars: repository.stargazersCount,
            subscriber: subscriber
        )
    }
    
    // MARK: - PRIVATE METHODS
    
    private func updateApiKeyInServiceApi() {
        let apiKey = try? keychainManager.retrieve(for: .apiKey)
        gitHubAPI.setAuthorizationToken(apiKey)
    }
}
