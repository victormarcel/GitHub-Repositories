//
//  KeychainOperationError.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

import Security

enum KeychainOperationError: Error {
    
    case saveFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case invalidData
}
