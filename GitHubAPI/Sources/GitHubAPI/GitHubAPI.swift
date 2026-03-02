import Foundation

/// A very basic type used to interact with the GitHub API.
///
/// You may choose to add new functions here if you would like to access new endpoints. Don't worry
/// about improving this type (e.g. removing duplication); just add what you need.
public struct GitHubAPI: Sendable {
    
    // MARK: - CONSTANTS
    
    private enum Constants {
        
        enum StatusCode {
            static let successRange = (200...299)
            static let unauthorized = 401
            static let notFound = 404
        }
    }
    
    // MARK: - PRIVATE PROPERTIES
    
    private let baseURL: URL
    private var authorizationToken: String?
    private let urlSession: URLSession
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // MARK: - INITIALIZERS
    
    /// Creates a new object for interacting with the GitHub API.
    ///
    /// - parameter baseURL: The base URL for the GitHub API. Defaults to `https://api.github.com`.
    /// - parameter authorisationToken: An optional authorisation token to use when authenticating.
    /// - parameter urlSession: The URL session to use for network requests. Defaults to `.shared`.
    public init(
        baseURL: URL = URL(string: "https://api.github.com")!,
        authorizationToken: String? = nil,
        urlSession: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.authorizationToken = authorizationToken
        self.urlSession = urlSession
    }
    
    // MARK: - PUBLIC METHODS
    
    /// Retrieves the repositories for a given organisation.
    ///
    /// - parameter organisation: The name of the organisation to retrieve repositories for.
    /// - returns: An array of `GitHubMinimalRepository` objects representing the repositories for
    ///   the provided organisation.
    public func repositoriesForOrganisation(_ organisation: String) async throws -> [GitHubMinimalRepository] {
        let url = baseURL.appendingPathComponent("orgs/\(organisation)/repos")
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        if let authorizationToken {
            request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await fetchData(for: request)
        return try handleResponse(response, data: data)
    }
    
    /// Retrieves a specific repository by its full name. The full name should be a value returned
    /// by the GitHub API and is in the form `<owner>/<repository>`.
    ///
    /// - parameter fullName: The full name of the repository to retrieve.
    /// - returns: A `GitHubFullRepository` object representing the repository.
    public func repository(_ fullName: String) async throws -> GitHubFullRepository {
        let url = baseURL.appendingPathComponent("repos/\(fullName)")
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        if let authorizationToken {
            request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await fetchData(for: request)
        return try handleResponse(response, data: data)
    }
    
    public mutating func setAuthorizationToken(_ token: String?) {
        authorizationToken = token
    }
    
    // MARK: - PRIVATE METHODS
    
    /// Performs an asynchronous network request and returns the raw response.
    ///
    /// - Parameter request: The `URLRequest` to be executed.
    /// - Returns: A tuple containing the raw `Data` and `URLResponse` returned by the server.
    /// - Throws: `URLError` if the request fails due to network connectivity issues.

    private func fetchData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await Task.sleep(for: .seconds(1))
        return try await urlSession.data(for: request)
    }
    
    /// Validates the HTTP response and decodes the response body into the specified type.
    /// Throws a `GitHubAPIError` if the response is invalid, unsuccessful, or cannot be decoded.
    ///
    /// - Parameters:
    ///   - response: The raw `URLResponse` received from the network request.
    ///   - data: The raw `Data` returned alongside the response.
    private func handleResponse<T: Codable>(_ response: URLResponse, data: Data) throws(GitHubAPIError) -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        
        guard Constants.StatusCode.successRange.contains(httpResponse.statusCode) else {
            try handleError(by: httpResponse)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .parserError(error)
        }
    }
    
    /// Maps an unsuccessful HTTP status code to its corresponding `GitHubAPIError`.
    /// This method always throws and never returns normally.
    ///
    /// - Parameter response: The `HTTPURLResponse` containing the status code to evaluate.
    private func handleError(by response: HTTPURLResponse) throws(GitHubAPIError) -> Never {
        switch response.statusCode {
        case Constants.StatusCode.unauthorized: throw .unauthorized
        case Constants.StatusCode.notFound: throw .notFound
        default: throw .serviceError(response.description)
        }
    }
}
