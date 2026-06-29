//
//  OwnedPiece.swift
//  hermes-vip-concept
//
//

import Foundation

/// A piece the member already owns ("Ma collection").
nonisolated struct OwnedPiece: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: String
    let material: String
    let color: String
    let year: Int
    let imageAssets: [String]

    init(
        id: String,
        name: String,
        category: String,
        material: String,
        color: String,
        year: Int,
        imageAssets: [String]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.material = material
        self.color = color
        self.year = year
        self.imageAssets = imageAssets
    }
}

nonisolated extension OwnedPiece {
    static let sample = samples[0]

    static let samples: [OwnedPiece] = [
        OwnedPiece(
            id: "own-001",
            name: "Sac Roulis mini",
            category: "Maroquinerie",
            material: "Veau Evercolor",
            color: "Noir",
            year: 2024,
            imageAssets: ["sac-roulis-mini-0"]
        ),
        OwnedPiece(
            id: "own-002",
            name: "Carré 90 Brides de Gala au Fil de Soie",
            category: "Soie",
            material: "Twill de soie",
            color: "Orange",
            year: 2023,
            imageAssets: ["carre-90-brides-de-gala-au-fil-de-soie-0"]
        ),
        OwnedPiece(
            id: "own-003",
            name: "Ceinture réversible Otto 32",
            category: "Accessoires",
            material: "Veau Epsom/Swift",
            color: "Noir/Gold",
            year: 2023,
            imageAssets: ["ceinture-reversible-otto-32-0"]
        ),
        OwnedPiece(
            id: "own-004",
            name: "Sac In-the-Loop 18",
            category: "Maroquinerie",
            material: "Veau Clemence",
            color: "Beige/Naturel",
            year: 2022,
            imageAssets: ["sac-hermes-in-the-loop-18-"]
        ),
        OwnedPiece(
            id: "own-005",
            name: "Carré 90 City of Light",
            category: "Soie",
            material: "Twill de soie",
            color: "Rose",
            year: 2025,
            imageAssets: ["carre-90-city-of-light-0"]
        )
    ]
}
