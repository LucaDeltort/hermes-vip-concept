//
//  HomeFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct HomeFlow: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreen()
                .appFlowDestinations()
        }
        .tint(Color(.accent))
        .tabBarVisibility(isPathEmpty: path.isEmpty)
    }
}

#Preview {
    HomeFlow()
        .environment(BookingCoordinator())
        .environment(ConversationCoordinator())
        .preferredColorScheme(.dark)
}
