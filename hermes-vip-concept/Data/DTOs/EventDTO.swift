//
//  EventDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct EventDTO: Codable, Sendable, Equatable {
    let id: String?
    let title: String?
    let location: String?
    let date: Date?
    let summary: String?
    let eyebrow: String?
    let imageAsset: String?

    var toEntity: Event {
        Event(
            id: id ?? "unknown-\(title ?? "")",
            title: title ?? "",
            location: location ?? "",
            date: date ?? Date(),
            summary: summary ?? "",
            eyebrow: eyebrow ?? "",
            imageAsset: imageAsset
        )
    }
}
