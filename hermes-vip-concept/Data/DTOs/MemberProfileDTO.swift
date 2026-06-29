//
//  MemberProfileDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct MemberProfileDTO: Codable, Sendable, Equatable {
    let id: String?
    let name: String?
    let tier: String?
    let memberSince: Date?
    let email: String?
    let advisor: AdvisorDTO?
    let avatarAsset: String?

    var toEntity: MemberProfile {
        MemberProfile(
            id: id ?? "unknown-\(email ?? name ?? "")",
            name: name ?? "",
            tier: tier ?? "",
            memberSince: memberSince ?? Date(),
            email: email ?? "",
            advisor: advisor?.toEntity,
            avatarAsset: avatarAsset
        )
    }
}
