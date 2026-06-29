//
//  ConversationFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// App-level coordinator for the conversation flow, injected into the
/// environment by `RootTabView`. Any screen can open the chat via `present()`.
@Observable
final class ConversationCoordinator {
    var isPresented: Bool = false

    func present() {
        isPresented = true
    }

    func dismiss() {
        isPresented = false
    }
}

/// Conversation thread hosted in its own `NavigationStack` inside the cover.
struct ConversationFlowView: View {
    let onClose: () -> Void
    @State private var advisor: Advisor?
    /// The chat is a `fullScreenCover`, so it can't rely on the booking
    /// coordinator injected by `RootTabView` (cover content doesn't inherit it),
    /// nor present `RootTabView`'s booking cover over itself. It hosts its own,
    /// so a product pushed from the thread can open the detail + booking flow.
    @State private var booking = BookingCoordinator()

    var body: some View {
        NavigationStack {
            ConversationScreen(onAdvisorLoaded: { advisor = $0 })
                .appFlowDestinations()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .tint(Color(.textSecondary))
                        .accessibilityLabel("Fermer")
                    }
                    ToolbarItem(placement: .principal) {
                        if let advisor {
                            HStack(spacing: Theme.Spacing.sm) {
                                ProductImageView(
                                    assets: [advisor.portraitAsset].compactMap { $0 },
                                    cornerRadius: 20
                                )
                                .frame(width: 32, height: 32)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(advisor.name)
                                        .font(Theme.Font.display(15))
                                        .foregroundStyle(Color(.textPrimary))
                                    Text(advisor.boutique)
                                        .font(Theme.Font.mono(8))
                                        .tracking(Theme.Tracking.wide(8))
                                        .foregroundStyle(Color(.textMuted))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
        }
        .environment(booking)
        .tint(Color(.accent))
        .preferredColorScheme(.dark)
        .fullScreenCover(item: $booking.request) { request in
            BookingFlowView(
                products: request.products,
                onClose: { booking.dismiss() },
                onCompleted: {
                    booking.complete()
                    booking.dismiss()
                }
            )
        }
    }
}
