//
//  SportyFactory+GitHubApiKey.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import UIKit

extension SportyFactory {
    
    func makeGitHubApiKeyAlertController() -> GitHubApiKeyPersistanceAlert {
        return GitHubApiKeyPersistanceAlert(keychainManager: KeychainManager())
    }
}
