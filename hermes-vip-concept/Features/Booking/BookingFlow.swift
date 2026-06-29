//
//  BookingFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// Identifiable payload that drives the booking cover.
struct BookingRequest: Identifiable {
    let id = UUID()
    let products: [Product]
}

/// App-level coordinator for the booking flow, injected into the environment by
/// `RootTabView`. Any screen can start a booking via `present(for:)`.
@Observable
final class BookingCoordinator {
    var request: BookingRequest?
    /// Bumped on each confirmed booking so observers can refresh.
    private(set) var completedCount = 0

    func present(for products: [Product]) {
        request = BookingRequest(products: products)
    }

    func complete() {
        completedCount += 1
    }

    func dismiss() {
        request = nil
    }
}

/// Booking → Confirmation. The booking screen lives in a `NavigationStack`
/// inside the cover; confirmation slides up over it as a frosted-glass sheet.
struct BookingFlowView: View {
    let products: [Product]
    let onClose: () -> Void
    let onCompleted: () -> Void

    @State private var confirmed: Appointment?

    var body: some View {
        NavigationStack {
            BookingScreen(products: products) { appointment in
                confirmed = appointment
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .tint(Color(.textSecondary))
                    .accessibilityLabel("Fermer")
                }
            }
        }
        .tint(Color(.accent))
        .preferredColorScheme(.dark)
        .sheet(item: $confirmed) { appointment in
            ConfirmationScreen(
                appointment: appointment,
                products: products,
                onDone: onCompleted
            )
            .presentationDetents([.fraction(0.66)])
            .presentationCornerRadius(Theme.Radius.tabBar)
            .presentationDragIndicator(.hidden)
            .presentationBackground { ConfirmationSheetBackground() }
        }
    }
}
