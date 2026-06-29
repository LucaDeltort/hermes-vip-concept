//
//  Advisor.swift
//  hermes-vip-concept
//
//

import Foundation

/// A personal advisor ("conseiller·ère") attached to the member.
nonisolated struct Advisor: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let title: String
    let boutique: String
    let introduction: String
    let portraitAsset: String?

    init(
        id: String,
        name: String,
        title: String,
        boutique: String,
        introduction: String,
        portraitAsset: String?
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.boutique = boutique
        self.introduction = introduction
        self.portraitAsset = portraitAsset
    }
}

nonisolated extension Advisor {
    static let sample = Advisor(
        id: "adv-001",
        name: "Élise Vaubourg",
        title: "Votre conseillère personnelle",
        boutique: "Hermès — 24 Faubourg",
        introduction:
            "Votre conseillère personnelle, à votre écoute, au rythme de la maison.",
        portraitAsset: "Elise_Vaubourg"
    )
}
