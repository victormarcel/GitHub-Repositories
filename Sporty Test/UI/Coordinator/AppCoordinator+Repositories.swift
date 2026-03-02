//
//  AppCoordinator+Repositories.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import Foundation
import GitHubAPI

extension AppCoordinator: RepositoriesViewControllerDelegate {
    
    func repositoriesViewControllerDidTapOnKeyButton(viewController: RepositoriesViewController) {
        presentGitHubApiKeyAlertController()
    }
    
    func repositoriesViewController(
        viewController: RepositoriesViewController,
        didTapOn repository: GitHubMinimalRepository
    ) {
        navigateToRepositoryScreen(repository: repository)
    }
}
