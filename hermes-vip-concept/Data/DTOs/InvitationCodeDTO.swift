//
//  InvitationCodeDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct InvitationCodeDTO: Codable, Sendable, Equatable {
    let id: String?
    let code: String?
    let valid: Bool?
    let memberName: String?

    /// Map the (optional, wire-shaped) DTO into the non-optional domain entity.
    var toEntity: InvitationCode {
        InvitationCode(
            id: id ?? "unknown-\(code ?? "")",
            code: code ?? "",
            isValid: valid ?? false,
            memberName: memberName ?? ""
        )
    }
}
