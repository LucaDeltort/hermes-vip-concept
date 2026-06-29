//
//  InvitationRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// Validates invitation codes.
protocol InvitationRepository: Sendable {
    func validate(code: String) async throws -> InvitationCode
}
