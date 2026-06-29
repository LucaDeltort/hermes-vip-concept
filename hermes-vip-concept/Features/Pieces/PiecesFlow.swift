//
//  PiecesFlow.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct PiecesFlow: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            PiecesScreen()
                .appFlowDestinations()
        }
        .tint(Color(.accent))
        .tabBarVisibility(isPathEmpty: path.isEmpty)
    }
}

#Preview {
    PiecesFlow()
        .preferredColorScheme(.dark)
}
