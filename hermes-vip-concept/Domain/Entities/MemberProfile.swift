//
//  MemberProfile.swift
//  hermes-vip-concept
//
//

import Foundation

/// The member's profile, shown on "Profil" and used for the welcome screen.
nonisolated struct MemberProfile: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let tier: String
    let memberSince: Date
    let email: String
    let advisor: Advisor?
    let avatarAsset: String?

    init(
        id: String,
        name: String,
        tier: String,
        memberSince: Date,
        email: String,
        advisor: Advisor?,
        avatarAsset: String?
    ) {
        self.id = id
        self.name = name
        self.tier = tier
        self.memberSince = memberSince
        self.email = email
        self.advisor = advisor
        self.avatarAsset = avatarAsset
    }
}

nonisolated extension MemberProfile {
    static let sample = MemberProfile(
        id: "mbr-001",
        name: "Camille L.",
        tier: "Membre Hermès",
        memberSince: Date(timeIntervalSince1970: 1_640_995_200), // 2022
        email: "camille.lautrec@example.com",
        advisor: .sample,
        avatarAsset: nil
    )
}
