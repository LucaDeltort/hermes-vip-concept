//
//  Conversation.swift
//  hermes-vip-concept
//
//

import Foundation

/// Who authored a message in the advisor conversation.
nonisolated enum MessageSender: String, Hashable, Sendable {
    case member
    case advisor
}

/// A single chat message in the "Conversation" thread.
nonisolated struct Message: Identifiable, Hashable, Sendable {
    let id: String
    let sender: MessageSender
    let text: String
    let timestamp: Date
    /// A product attached by the advisor, rendered as a tappable card bubble.
    let product: Product?

    init(
        id: String,
        sender: MessageSender,
        text: String,
        timestamp: Date,
        product: Product? = nil
    ) {
        self.id = id
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
        self.product = product
    }
}

/// The full conversation between the member and their advisor.
nonisolated struct Conversation: Identifiable, Hashable, Sendable {
    let id: String
    let advisor: Advisor
    let messages: [Message]

    init(id: String, advisor: Advisor, messages: [Message]) {
        self.id = id
        self.advisor = advisor
        self.messages = messages
    }
}

nonisolated extension Conversation {
    static let sample = Conversation(
        id: "cnv-001",
        advisor: .sample,
        messages: [
            Message(
                id: "msg-001",
                sender: .advisor,
                text: "Bonjour Camille, ravie de vous retrouver. "
                    + "Avez-vous pu réfléchir à la teinte du Birkin ?",
                timestamp: Date(timeIntervalSince1970: 1_782_200_000)
            ),
            Message(
                id: "msg-002",
                sender: .member,
                text: "Bonjour Élise ! Oui, l'Étoupe me plaît beaucoup.",
                timestamp: Date(timeIntervalSince1970: 1_782_200_600)
            ),
            Message(
                id: "msg-003",
                sender: .advisor,
                text: "Excellent choix. Je vous prépare une présentation privée.",
                timestamp: Date(timeIntervalSince1970: 1_782_201_200)
            ),
            Message(
                id: "msg-004",
                sender: .advisor,
                text: "J'ai également mis de côté une pièce qui devrait vous plaire.",
                timestamp: Date(timeIntervalSince1970: 1_782_201_800)
            ),
            Message(
                id: "msg-005",
                sender: .advisor,
                text: "",
                timestamp: Date(timeIntervalSince1970: 1_782_201_900),
                product: Product.samples[0]
            )
        ]
    )
}
