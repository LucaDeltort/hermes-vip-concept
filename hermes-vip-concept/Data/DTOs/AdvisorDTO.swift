//
//  AdvisorDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct AdvisorDTO: Codable, Sendable, Equatable {
    let id: String?
    let name: String?
    let title: String?
    let boutique: String?
    let introduction: String?
    let portraitAsset: String?

    var toEntity: Advisor {
        Advisor(
            id: id ?? "unknown-\(name ?? "")",
            name: name ?? "",
            title: title ?? "",
            boutique: boutique ?? "",
            introduction: introduction ?? "",
            portraitAsset: portraitAsset
        )
    }
}
