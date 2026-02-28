//
//  SportyFactory+Repository.swift
//  Sporty Test
//
//  Created by Victor Marcel on 27/02/26.
//

import Foundation
import GitHubAPI

extension SportyFactory {
    
    func makeRepositoryViewController(repository: GitHubMinimalRepository) -> RepositoryViewController {
        return .init(minimalRepository: repository, gitHubAPI: GitHubAPI())
    }
}
