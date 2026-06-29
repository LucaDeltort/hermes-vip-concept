//
//  RootTabView.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct RootTabView: View {
    /// Selectable tabs. Named `AppTab` to avoid colliding with SwiftUI's `Tab`.
    enum AppTab: Hashable {
        case home, grid, events, profile
    }

    @State private var selection: AppTab = .home
    /// Drives the booking flow, presented as a cover so the native tab bar
    /// stays put instead of having to animate back in.
    @State private var booking = BookingCoordinator()
    @State private var conversation = ConversationCoordinator()

    var body: some View {
        TabView(selection: $selection) {
            Tab("Accueil", systemImage: "house", value: AppTab.home) {
                HomeFlow()
            }
            Tab("Collection", systemImage: "square.grid.2x2", value: AppTab.grid) {
                PiecesFlow()
            }
            Tab("Événements", systemImage: "calendar", value: AppTab.events) {
                EventsFlow()
            }
            Tab("Profil", systemImage: "person", value: AppTab.profile) {
                ProfileFlow()
            }
        }
        .tint(Color(.accent))
        .environment(booking)
        .environment(conversation)
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
        .fullScreenCover(isPresented: $conversation.isPresented) {
            ConversationFlowView(onClose: { conversation.dismiss() })
        }
    }
}

#Preview {
    RootTabView()
        .preferredColorScheme(.dark)
}
