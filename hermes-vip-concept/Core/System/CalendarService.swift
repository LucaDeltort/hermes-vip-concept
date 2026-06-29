//
//  CalendarService.swift
//  hermes-vip-concept
//
//

import EventKit
import Foundation

enum CalendarService {
    /// Outcome of an "add to calendar" attempt.
    enum AddResult {
        case added
        /// Calendar access was refused (or restricted by the device).
        case denied
        /// Access granted but the event could not be saved.
        case failed
    }

    /// Default visit duration when the event carries only a start time.
    private static let defaultDuration: TimeInterval = 2 * 60 * 60

    /// Request write-only calendar access and save `event` to the default calendar.
    static func add(_ event: Event) async -> AddResult {
        let store = EKEventStore()

        let granted: Bool
        do {
            granted = try await store.requestWriteOnlyAccessToEvents()
        } catch {
            return .denied
        }
        guard granted else { return .denied }

        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = event.title
        ekEvent.startDate = event.date
        ekEvent.endDate = event.date.addingTimeInterval(defaultDuration)
        ekEvent.location = event.location
        ekEvent.notes = event.summary
        ekEvent.calendar = store.defaultCalendarForNewEvents

        do {
            try store.save(ekEvent, span: .thisEvent)
            return .added
        } catch {
            return .failed
        }
    }
}
