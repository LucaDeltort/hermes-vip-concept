//
//  APIRepositorySupport.swift
//  hermes-vip-concept
//
//

import Foundation

/// Decodable placeholder for endpoints that return no meaningful body (e.g. a
/// `DELETE`). Decodes from an empty JSON object `{}`.
nonisolated struct EmptyResponse: Decodable, Sendable {}

extension APIError {
    /// Map a transport error into the domain error surfaced to view models.
    var asRepositoryError: RepositoryError {
        switch self {
        case .transport:                 return .network
        case .decoding:                  return .decoding
        case .status(let code):          return code == 404 ? .notFound : .network
        case .unhandledEndpoint(let p):  return .resourceMissing(p)
        }
    }
}

/// Run an API call and normalise any thrown error to `RepositoryError`.
func mappingAPIErrors<T>(_ operation: () async throws -> T) async throws -> T {
    do {
        return try await operation()
    } catch let error as APIError {
        throw error.asRepositoryError
    } catch let error as RepositoryError {
        throw error
    } catch {
        throw RepositoryError.network
    }
}
