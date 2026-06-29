//
//  BookingViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension BookingScreen {
    struct ViewData: Equatable {
        let slots: [BookingSlot]
    }

    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let bookingRepository: BookingRepository

        var state: AsyncUIState<ViewData> = .idle
        var selectedDay: Date?
        var selectedSlot: BookingSlot?
        var isBooking = false
        var bookingError: LocalizedStringKey?

        init(bookingRepository: BookingRepository? = nil) {
            self.bookingRepository = bookingRepository ?? AppContainer.shared.bookingRepository()
        }

        var canConfirm: Bool { selectedSlot != nil && !isBooking }

        func load() async {
            state = .loading
            do {
                let slots = try await bookingRepository.availableSlots(forMonth: Date())
                state = .data(ViewData(slots: slots))
                // Default-select the first available slot's day + slot.
                if let first = slots.first(where: \.isAvailable) {
                    selectedDay = Calendar.maison.startOfDay(for: first.date)
                    selectedSlot = first
                }
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }

        func selectDay(_ day: Date) {
            selectedDay = day
            // Drop a slot selection that no longer belongs to the chosen day.
            if let slot = selectedSlot, !Calendar.maison.isDate(slot.date, inSameDayAs: day) {
                selectedSlot = nil
            }
        }

        func select(_ slot: BookingSlot) {
            guard slot.isAvailable else { return }
            selectedSlot = slot
        }

        /// Book the selected slot. Returns the confirmed appointment on success.
        func book() async -> Appointment? {
            guard let slot = selectedSlot, !isBooking else { return nil }
            isBooking = true
            bookingError = nil
            defer { isBooking = false }
            do {
                return try await bookingRepository.book(slot: slot)
            } catch {
                bookingError = "La réservation a échoué. Veuillez réessayer."
                return nil
            }
        }
    }
}
