//
//  EventsFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct EventsFlow: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            EventsScreen()
                .appFlowDestinations()
        }
        .tint(Color(.accent))
        .tabBarVisibility(isPathEmpty: path.isEmpty)
    }
}

#Preview {
    EventsFlow()
        .preferredColorScheme(.dark)
}
