//
//  EditorialMoment.swift
//  hermes-vip-concept
//
//

import Foundation

/// An editorial story tile ("Moments Hermès") shown on the home feed.
nonisolated struct EditorialMoment: Identifiable, Hashable, Sendable {
    let id: String
    let eyebrow: String
    let title: String
    let quote: String
    let imageAsset: String?

    init(id: String, eyebrow: String, title: String, quote: String, imageAsset: String?) {
        self.id = id
        self.eyebrow = eyebrow
        self.title = title
        self.quote = quote
        self.imageAsset = imageAsset
    }
}

nonisolated extension EditorialMoment {
    static let sample = EditorialMoment(
        id: "edt-001",
        eyebrow: "L'ATELIER",
        title: "La main et la matière",
        quote: "« Le luxe, c'est ce qui ne se voit pas mais qui se ressent. »",
        imageAsset: "luxe-ressent"
    )

    static let samples: [EditorialMoment] = [
        .sample,
        EditorialMoment(
            id: "edt-002",
            eyebrow: "SAVOIR-FAIRE",
            title: "Le cuir, du tannage au point sellier",
            quote: "« Une seule artisane, un seul sac, du premier au dernier point. »",
            imageAsset: "sac-femme"
        )
    ]
}
