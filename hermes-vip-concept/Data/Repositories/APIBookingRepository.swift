//
//  APIBookingRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// `BookingRepository` backed by an `APIClient`.
struct APIBookingRepository: BookingRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func nextAppointment() async throws -> Appointment? {
        try await mappingAPIErrors {
            // Optional decode: the API returns `null` when no visit is scheduled
            // (e.g. after the member cancels their appointment).
            let dto: AppointmentDTO? = try await client.request(Endpoint.Booking.nextAppointment())
            return dto?.toEntity
        }
    }

    func availableSlots(forMonth month: Date) async throws -> [BookingSlot] {
        try await mappingAPIErrors {
            let dtos: [BookingSlotDTO] = try await client.request(
                Endpoint.Booking.slots(month: month)
            )
            return dtos.map(\.toEntity)
        }
    }

    func book(slot: BookingSlot) async throws -> Appointment {
        try await mappingAPIErrors {
            let dto: AppointmentDTO = try await client.request(
                Endpoint.Booking.book(slotID: slot.id)
            )
            return dto.toEntity
        }
    }

    func cancel(appointment: Appointment) async throws {
        try await mappingAPIErrors {
            let _: EmptyResponse = try await client.request(
                Endpoint.Booking.cancel(appointmentID: appointment.id)
            )
        }
    }
}
