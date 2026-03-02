//
//  SportyFactory+Repository.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import GitHubAPI
import UIKit

extension SportyFactory {
    
    func makeRepositoryViewController(repository: GitHubMinimalRepository) -> UIViewController {
        return RepositoryView(minimalRepository: repository, gitHubAPI: .init()).embeddedInViewController()
    }
}
