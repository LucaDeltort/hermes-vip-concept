//
//  APIClient.swift
//  hermes-vip-concept
//
//

import Foundation

/// Errors thrown by an `APIClient`, mapped to `RepositoryError` by repositories.
enum APIError: Error, Equatable {
    case transport
    case status(Int)
    case decoding
    case unhandledEndpoint(String)
}

/// Async HTTP client. Repositories depend on this protocol; the concrete
/// client (mock or `URLSession`) is chosen via DI.
protocol APIClient: Sendable {
    /// Perform `endpoint` and decode the JSON response into `T`.
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}

extension APIClient {
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        try await request(endpoint, as: T.self)
    }
}
