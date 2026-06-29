//
//  APIInvitationRepository.swift
//  hermes-vip-concept
//
//

import Foundation

struct APIInvitationRepository: InvitationRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func validate(code: String) async throws -> InvitationCode {
        try await mappingAPIErrors {
            let dto: InvitationCodeDTO = try await client.request(
                Endpoint.Invitation.validate(code: code)
            )
            return dto.toEntity
        }
    }
}
