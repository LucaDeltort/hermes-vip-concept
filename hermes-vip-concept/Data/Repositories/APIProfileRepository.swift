//
//  APIProfileRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// `ProfileRepository` backed by an `APIClient`.
struct APIProfileRepository: ProfileRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func profile() async throws -> MemberProfile {
        try await mappingAPIErrors {
            let dto: MemberProfileDTO = try await client.request(Endpoint.Profile.profile())
            return dto.toEntity
        }
    }

    func advisor() async throws -> Advisor {
        try await mappingAPIErrors {
            let dto: AdvisorDTO = try await client.request(Endpoint.Profile.advisor())
            return dto.toEntity
        }
    }
}
