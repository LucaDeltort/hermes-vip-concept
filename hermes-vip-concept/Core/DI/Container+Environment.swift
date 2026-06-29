//
//  Container+Environment.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension EnvironmentValues {
    /// The shared app-state manager.
    @Entry var appStateManager: AppStateManager = AppContainer.shared.appState()
}
