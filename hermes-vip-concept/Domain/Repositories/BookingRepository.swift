//
//  BookingRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// Appointments and the booking flow.
protocol BookingRepository: Sendable {
    func nextAppointment() async throws -> Appointment?
    func availableSlots(forMonth month: Date) async throws -> [BookingSlot]
    func book(slot: BookingSlot) async throws -> Appointment
    func cancel(appointment: Appointment) async throws
}
