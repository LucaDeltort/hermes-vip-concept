//
//  APIConversationRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// `ConversationRepository` backed by an `APIClient`.
struct APIConversationRepository: ConversationRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func conversation() async throws -> Conversation {
        try await mappingAPIErrors {
            let dto: ConversationDTO = try await client.request(Endpoint.Conversation.thread())
            return dto.toEntity
        }
    }

    func send(text: String) async throws -> Conversation {
        try await mappingAPIErrors {
            let dto: ConversationDTO = try await client.request(
                Endpoint.Conversation.send(text: text)
            )
            return dto.toEntity
        }
    }
}
