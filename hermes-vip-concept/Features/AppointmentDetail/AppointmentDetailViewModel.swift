//
//  AppointmentDetailViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension AppointmentDetailScreen {
    /// State of the "add to calendar" action.
    enum CalendarState {
        case idle, adding, added, failed
    }

    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let bookingRepository: BookingRepository

        /// The visit being shown, and the favorited pieces it was booked for.
        let appointment: Appointment
        let products: [Product]

        var calendarState: CalendarState = .idle
        var isCancelling = false
        var cancelError: LocalizedStringKey?

        init(
            appointment: Appointment,
            products: [Product],
            bookingRepository: BookingRepository? = nil
        ) {
            self.appointment = appointment
            self.products = products
            self.bookingRepository = bookingRepository ?? AppContainer.shared.bookingRepository()
        }

        /// Request write-only calendar access and save the visit.
        func addToCalendar() async {
            guard calendarState == .idle || calendarState == .failed else { return }
            calendarState = .adding
            let event = Event(
                id: appointment.id,
                title: appointment.title,
                location: appointment.boutique,
                date: appointment.date,
                summary: "Avec \(appointment.advisorName)",
                eyebrow: "RENDEZ-VOUS",
                imageAsset: nil
            )
            let result = await CalendarService.add(event)
            calendarState = result == .added ? .added : .failed
        }

        /// Cancel the visit. Returns `true` on success.
        func cancel() async -> Bool {
            guard !isCancelling else { return false }
            isCancelling = true
            cancelError = nil
            do {
                try await bookingRepository.cancel(appointment: appointment)
                isCancelling = false
                return true
            } catch let error as RepositoryError {
                cancelError = LocalizedStringKey(error.localizedDescription)
                isCancelling = false
                return false
            } catch {
                cancelError = "Une erreur est survenue."
                isCancelling = false
                return false
            }
        }
    }
}
