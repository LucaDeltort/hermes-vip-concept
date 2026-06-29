//
//  InvitationCode.swift
//  hermes-vip-concept
//
//

import Foundation

/// The outcome of submitting an invitation code on the "Code d'invitation" screen.
nonisolated struct InvitationCode: Identifiable, Hashable, Sendable {
    let id: String
    let code: String
    let isValid: Bool
    let memberName: String

    init(id: String, code: String, isValid: Bool, memberName: String) {
        self.id = id
        self.code = code
        self.isValid = isValid
        self.memberName = memberName
    }
}

nonisolated extension InvitationCode {
    static let sample = InvitationCode(
        id: "inv-001",
        code: "HERMES-2026",
        isValid: true,
        memberName: "Camille"
    )
}
