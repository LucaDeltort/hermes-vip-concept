//
//  Appointment.swift
//  hermes-vip-concept
//
//

import Foundation

/// A confirmed or upcoming boutique visit. Surfaced on the home screen
/// ("votre prochain rendez-vous") and produced by the booking flow.
nonisolated struct Appointment: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let boutique: String
    let date: Date
    let advisorName: String

    init(id: String, title: String, boutique: String, date: Date, advisorName: String) {
        self.id = id
        self.title = title
        self.boutique = boutique
        self.date = date
        self.advisorName = advisorName
    }
}

/// A single bookable time slot on the "Réserver une visite" calendar.
nonisolated struct BookingSlot: Identifiable, Hashable, Sendable {
    let id: String
    let date: Date
    let label: String
    let isAvailable: Bool

    init(id: String, date: Date, label: String, isAvailable: Bool) {
        self.id = id
        self.date = date
        self.label = label
        self.isAvailable = isAvailable
    }
}

nonisolated extension Appointment {
    static let sample = Appointment(
        id: "apt-001",
        title: "Présentation privée — Maroquinerie",
        boutique: "Hermès — 24 Faubourg",
        date: Date(timeIntervalSince1970: 1_782_997_200), // Thu 2 July 2026, 15:00 Paris
        advisorName: "Élise Vaubourg"
    )
}

nonisolated extension BookingSlot {
    /// A morning-to-evening grid of slots for a given day, for previews/mocks.
    static func samples(on day: Date = Date(timeIntervalSince1970: 1_782_943_200)) -> [BookingSlot] {
        let calendar = Calendar(identifier: .gregorian)
        let hours = [10, 11, 14, 15, 16, 17]
        return hours.enumerated().map { index, hour in
            let date = calendar.date(
                bySettingHour: hour, minute: 0, second: 0, of: day
            ) ?? day
            return BookingSlot(
                id: "slot-\(hour)",
                date: date,
                label: String(format: "%02d:00", hour),
                isAvailable: index != 2
            )
        }
    }
}
