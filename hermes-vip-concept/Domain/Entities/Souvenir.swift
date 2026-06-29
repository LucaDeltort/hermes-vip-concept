//
//  Souvenir.swift
//  hermes-vip-concept
//
//

import Foundation

/// A past event the member attended, kept as a small photo album.
nonisolated struct Souvenir: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let caption: String
    let photoAssets: [String]

    init(id: String, title: String, caption: String, photoAssets: [String]) {
        self.id = id
        self.title = title
        self.caption = caption
        self.photoAssets = photoAssets
    }
}

nonisolated extension Souvenir {
    static let sample = Souvenir(
        id: "souv-001",
        title: "Défilé Hiver",
        caption: "Photos souvenirs · Décembre 2025",
        photoAssets: [
            "carre-90-grand-galop-0",
            "faubourg-express-0",
            "sac-hermes-in-the-loop-18-"
        ]
    )

    static let samples: [Souvenir] = [
        .sample,
        Souvenir(
            id: "souv-002",
            title: "Dîner privé au Faubourg",
            caption: "Photos souvenirs · Septembre 2025",
            photoAssets: [
                "carre-140-le-pegase-d-hermes-0",
                "sandales-izmir-0",
                "bracelet-clic-clou-de-selle-0"
            ]
        )
    ]
}
