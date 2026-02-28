//
//  SportyFactoryProtocol.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import Foundation
import GitHubAPI

@MainActor
protocol SportyFactoryProtocol {
    
    func makeRepositoriesViewController(delegate: RepositoriesViewControllerDelegate?) -> RepositoriesViewController
    func makeRepositoryViewController(repository: GitHubMinimalRepository) -> RepositoryViewController
}
