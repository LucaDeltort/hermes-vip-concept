//
//  EditorialMomentDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct EditorialMomentDTO: Codable, Sendable, Equatable {
    let id: String?
    let eyebrow: String?
    let title: String?
    let quote: String?
    let imageAsset: String?

    var toEntity: EditorialMoment {
        EditorialMoment(
            id: id ?? "unknown-\(title ?? "")",
            eyebrow: eyebrow ?? "",
            title: title ?? "",
            quote: quote ?? "",
            imageAsset: imageAsset
        )
    }
}
