//
//  AppointmentDetailFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// Identifiable payload that drives the appointment-detail cover.
struct AppointmentDetailRequest: Identifiable {
    let id = UUID()
    let appointment: Appointment
    /// The favorited pieces the visit was booked for.
    let products: [Product]
}

struct AppointmentDetailFlowView: View {
    let appointment: Appointment
    let products: [Product]
    /// Dismiss without changes (X button).
    let onClose: () -> Void
    /// The visit was cancelled — dismiss and refresh the home screen.
    let onCancelled: () -> Void

    var body: some View {
        NavigationStack {
            AppointmentDetailScreen(
                appointment: appointment,
                products: products,
                onCancelled: onCancelled
            )
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
    }
}
