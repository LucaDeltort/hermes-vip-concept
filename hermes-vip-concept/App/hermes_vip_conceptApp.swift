//
//  hermes_vip_conceptApp.swift
//  hermes-vip-concept
//
//

import SwiftUI

@main
struct hermes_vip_conceptApp: App {
    /// The shared, app-wide state manager resolved from the composition root.
    @State private var appState = AppContainer.shared.appState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appStateManager, appState)
                .environment(appState)
                .preferredColorScheme(.dark) // dark-mode-only concept
        }
    }
}
