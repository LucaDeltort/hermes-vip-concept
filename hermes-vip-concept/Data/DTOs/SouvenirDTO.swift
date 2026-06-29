//
//  SouvenirDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct SouvenirDTO: Codable, Sendable, Equatable {
    let id: String?
    let title: String?
    let caption: String?
    let photoAssets: [String]?

    var toEntity: Souvenir {
        Souvenir(
            id: id ?? "unknown-\(title ?? "")",
            title: title ?? "",
            caption: caption ?? "",
            photoAssets: photoAssets ?? []
        )
    }
}
