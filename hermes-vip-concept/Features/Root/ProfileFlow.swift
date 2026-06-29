//
//  ProfileFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct ProfileFlow: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            ProfileScreen()
                .appFlowDestinations()
        }
        .tint(Color(.accent))
        .tabBarVisibility(isPathEmpty: path.isEmpty)
    }
}

#Preview {
    ProfileFlow()
        .environment(\.appStateManager, AppStateManager())
        .preferredColorScheme(.dark)
}
