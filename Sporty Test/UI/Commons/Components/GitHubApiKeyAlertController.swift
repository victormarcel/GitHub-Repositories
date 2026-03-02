//
//  GitHubApiKeyAlertController.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import UIKit

final class GitHubApiKeyPersistanceAlert: UIAlertController {
    
    // MARK: - CONSTANTS
    
    private enum Constants {
        static let title = "GitHub API Key"
        static let message = "Enter your personal access token to increase the API rate limit."
        static let placeholder = "ghp_xxxxxxxxxxxxxxxxxxxx"
        static let saveTitle = "Save"
        static let cancelTitle = "Cancel"
    }
    
    // MARK: - PRIVATE PROPERTIES
    
    private let keychainManager: KeychainManagerProtocol
    
    override var preferredStyle: UIAlertController.Style {
        return .alert
    }
    
    // MARK: - INITIALIZERS
    
    init(keychainManager: KeychainManagerProtocol) {
        self.keychainManager = keychainManager
        
        super.init(nibName: nil, bundle: nil)

        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PRIVATE METHODS
    
    private func setup() {
        setupLayout()
        
        addAction(UIAlertAction(title: Constants.cancelTitle, style: .cancel))
        addAction(UIAlertAction(title: Constants.saveTitle, style: .default) { [weak self] _ in
            guard let self, let apiKey = textFields?.first?.text, !apiKey.isEmpty else { return }
            save(apiKey: apiKey)
        })
    }
    
    private func setupLayout() {
        title = Constants.title
        message = Constants.message
        
        addTextField { textField in
            textField.placeholder = Constants.placeholder
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.spellCheckingType = .no
            textField.textContentType = .password
        }
    }
    
    private func save(apiKey text: String) {
        try? keychainManager.save(text, for: .apiKey)
    }
}
