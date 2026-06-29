//
//  ConversationRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// The chat thread with the member's personal advisor.
protocol ConversationRepository: Sendable {
    func conversation() async throws -> Conversation
    func send(text: String) async throws -> Conversation
}
