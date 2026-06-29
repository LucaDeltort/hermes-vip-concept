//
//  Event.swift
//  hermes-vip-concept
//
//

import Foundation

/// A private maison event the member can attend ("Événements").
nonisolated struct Event: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let location: String
    let date: Date
    let summary: String
    let eyebrow: String
    let imageAsset: String?

    init(
        id: String,
        title: String,
        location: String,
        date: Date,
        summary: String,
        eyebrow: String,
        imageAsset: String?
    ) {
        self.id = id
        self.title = title
        self.location = location
        self.date = date
        self.summary = summary
        self.eyebrow = eyebrow
        self.imageAsset = imageAsset
    }
}

nonisolated extension Event {
    static let sample = Event(
        id: "evt-001",
        title: "Vernissage — Hermès dans tous les sens",
        location: "Palais de Tokyo, Paris",
        date: Date(timeIntervalSince1970: 1_783_000_000),
        summary:
            "Une exposition immersive célébrant l'artisanat de la maison, "
            + "suivie d'un cocktail privé.",
        eyebrow: "SUR INVITATION",
        imageAsset: "luxe-ressent"
    )

    static let samples: [Event] = [
        .sample,
        Event(
            id: "evt-002",
            title: "Atelier carré de soie",
            location: "Hermès — 24 Faubourg",
            date: Date(timeIntervalSince1970: 1_784_500_000),
            summary: "Apprenez l'art du nouage en compagnie d'un artisan de la maison.",
            eyebrow: "ATELIER PRIVÉ",
            imageAsset: "carre-90-grand-galop-0"
        )
    ]
}
