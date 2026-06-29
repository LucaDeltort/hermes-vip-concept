//
//  AppointmentDTO.swift
//  hermes-vip-concept
//
//

import Foundation

nonisolated struct AppointmentDTO: Codable, Sendable, Equatable {
    let id: String?
    let title: String?
    let boutique: String?
    let date: Date?
    let advisorName: String?

    var toEntity: Appointment {
        Appointment(
            id: id ?? "unknown-\(title ?? "")",
            title: title ?? "",
            boutique: boutique ?? "",
            date: date ?? Date(),
            advisorName: advisorName ?? ""
        )
    }
}

nonisolated struct BookingSlotDTO: Codable, Sendable, Equatable {
    let id: String?
    let date: Date?
    let label: String?
    let available: Bool?

    var toEntity: BookingSlot {
        BookingSlot(
            id: id ?? "unknown-slot-\(date?.timeIntervalSince1970 ?? 0)",
            date: date ?? Date(),
            label: label ?? "",
            isAvailable: available ?? false
        )
    }
}
