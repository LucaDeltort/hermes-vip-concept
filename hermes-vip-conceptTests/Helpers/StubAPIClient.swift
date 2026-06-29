//
//  StubAPIClient.swift
//  hermes-vip-conceptTests
//
//

import Foundation
@testable import hermes_vip_concept

/// An `APIClient` whose response is driven by a closure, so each test controls
/// exactly what the "server" returns — including throwing for error paths.
final class StubAPIClient: APIClient, @unchecked Sendable {
    /// Return the raw JSON `Data` for the given endpoint, or throw.
    var handler: ((Endpoint) throws -> Data)?

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        guard let handler else { throw APIError.unhandledEndpoint(endpoint.path) }
        let data = try handler(endpoint)
        do {
            return try JSONDecoder.api.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
