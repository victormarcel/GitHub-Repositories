//
//  GitHubAPIError.swift
//  GitHubAPI
//
//  Created by Victor Marcel on 01/03/26.
//

public enum GitHubAPIError: Error, Equatable {
    
    case invalidResponse
    case notFound
    case parserError(Error)
    case serviceError(String)
    case unauthorized
    
    public static func == (lhs: GitHubAPIError, rhs: GitHubAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.notFound, .notFound),
             (.unauthorized, .unauthorized):
            return true
        case (.serviceError(let lhsMessage), .serviceError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.parserError(let lhsError), .parserError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
