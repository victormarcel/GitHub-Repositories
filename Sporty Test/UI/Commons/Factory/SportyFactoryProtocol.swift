//
//  SportyFactoryProtocol.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import GitHubAPI
import UIKit

@MainActor
protocol SportyFactoryProtocol {
    
    func makeRepositoriesViewController(delegate: RepositoriesViewControllerDelegate?) -> RepositoriesViewController
    func makeRepositoryViewController(repository: GitHubMinimalRepository) -> UIViewController
    func makeGitHubApiKeyAlertController() -> GitHubApiKeyPersistanceAlert
}
