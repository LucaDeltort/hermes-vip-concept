//
//  ProductDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct ProductDTO: Codable, Sendable, Equatable {
    let id: String?
    let name: String?
    let category: String?
    let material: String?
    let color: String?
    let description: String?
    let advisorNote: String?
    let badge: String?
    let imageAssets: [String]?
    let isFavorite: Bool?

    var toEntity: Product {
        Product(
            id: id ?? "unknown-\(name ?? "")",
            name: name ?? "",
            category: category ?? "",
            material: material ?? "",
            color: color ?? "",
            description: description ?? "",
            advisorNote: advisorNote,
            badge: badge.flatMap(ProductBadge.init(rawValue:)),
            imageAssets: imageAssets ?? [],
            isFavorite: isFavorite ?? false
        )
    }
}
