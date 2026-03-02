//
//  KeychainManager.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import Foundation
import Security

protocol KeychainManagerProtocol {
    
    func save(_ value: String, for key: KeychainKey) throws(KeychainOperationError)
    func retrieve(for key: KeychainKey) throws(KeychainOperationError) -> String
    func delete(for key: KeychainKey) throws(KeychainOperationError)
}

struct KeychainManager: KeychainManagerProtocol {

    // MARK: - CONSTANTS

    private enum Constants {
        static let defaultService = "com.app.keychain"
    }

    // MARK: - PRIVATE PROPERTIES

    private let service = Bundle.main.bundleIdentifier ?? Constants.defaultService

    // MARK: - INTERNAL METHODS

    func save(_ value: String, for key: KeychainKey) throws(KeychainOperationError) {
        guard let data = value.data(using: .utf8) else {
            throw .invalidData
        }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            throw .saveFailed(status)
        }
    }

    func retrieve(for key: KeychainKey) throws(KeychainOperationError) -> String {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw .retrieveFailed(status)
        }

        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw .invalidData
        }

        return value
    }

    func delete(for key: KeychainKey) throws(KeychainOperationError) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            throw .deleteFailed(status)
        }
    }
}
