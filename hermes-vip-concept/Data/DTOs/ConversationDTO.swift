//
//  ConversationDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct MessageDTO: Codable, Sendable, Equatable {
    let id: String?
    let sender: String?
    let text: String?
    let timestamp: Date?
    let product: ProductDTO?

    init(
        id: String?,
        sender: String?,
        text: String?,
        timestamp: Date?,
        product: ProductDTO? = nil
    ) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.product = product
    }

    var toEntity: Message {
        Message(
            id: id ?? "unknown-message-\(sender ?? "advisor")-\(text ?? "")",
            sender: MessageSender(rawValue: sender ?? "advisor") ?? .advisor,
            text: text ?? "",
            timestamp: timestamp ?? Date(),
            product: product?.toEntity
        )
    }
}

nonisolated struct ConversationDTO: Codable, Sendable, Equatable {
    let id: String?
    let advisor: AdvisorDTO?
    let messages: [MessageDTO]?

    var toEntity: Conversation {
        Conversation(
            id: id ?? "unknown-conversation",
            advisor: advisor?.toEntity ?? .sample,
            messages: (messages ?? []).map(\.toEntity)
        )
    }
}
