//
//  OwnedPieceDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct OwnedPieceDTO: Codable, Sendable, Equatable {
    let id: String?
    let name: String?
    let category: String?
    let material: String?
    let color: String?
    let year: Int?
    let imageAssets: [String]?

    var toEntity: OwnedPiece {
        OwnedPiece(
            id: id ?? "unknown-\(name ?? "")",
            name: name ?? "",
            category: category ?? "",
            material: material ?? "",
            color: color ?? "",
            year: year ?? 0,
            imageAssets: imageAssets ?? []
        )
    }
}
