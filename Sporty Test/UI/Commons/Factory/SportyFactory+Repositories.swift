//
//  SportyFactory+Repositories.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import Foundation
import GitHubAPI
import MockLiveServer

extension SportyFactory {
    
    func makeRepositoriesViewController(delegate: RepositoriesViewControllerDelegate?) -> RepositoriesViewController {
        let viewModel = RepositoriesViewModel(gitHubAPI: GitHubAPI(), mockLiveServer: MockLiveServer())
        let viewController = RepositoriesViewController(viewModel: viewModel)
        viewController.delegate = delegate
        
        return viewController
    }
}
