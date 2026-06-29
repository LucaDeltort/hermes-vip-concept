//
//  AppStateManager.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// Top-level app phase the root view switches on.
enum AppState: Equatable {
    case splash
    case onboarding
    case welcome
    case locked
    case authenticated
}

/// Owns the global `AppState`, injected via `@Environment`.
@MainActor
@Observable
final class AppStateManager {
    private(set) var state: AppState = .splash

    // MARK: - Demo session persistence
    private static let sessionKey = "demo.isAuthenticated"
    private static let biometricKey = "demo.biometricLock"

    /// When on, a resumed session is gated behind Face ID / Touch ID.
    var isBiometricLockEnabled: Bool {
        didSet { UserDefaults.standard.set(isBiometricLockEnabled, forKey: Self.biometricKey) }
    }

    init() {
        isBiometricLockEnabled = UserDefaults.standard.bool(forKey: Self.biometricKey)
    }

    private var hasPersistedSession: Bool {
        UserDefaults.standard.bool(forKey: Self.sessionKey)
    }

    private func persistSession(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Self.sessionKey)
    }

    func advanceToWelcome() {
        state = .welcome
    }

    func didCompleteOnboarding() {
        persistSession(true) // DEMO
        state = .authenticated
    }

    func beginOnboarding() {
        state = .onboarding
    }

    /// Resume a persisted session (locked if biometric lock is on), else onboard.
    func resumeFromSplash() {
        guard hasPersistedSession else { state = .onboarding; return } // DEMO
        state = isBiometricLockEnabled ? .locked : .authenticated
    }

    /// Prompt for Face ID / Touch ID; enter the maison on success.
    func unlock() async {
        let success = await BiometricAuthenticator.authenticate(
            reason: "Déverrouillez votre espace Hermès VIP."
        )
        if success { state = .authenticated }
    }

    func signOut() {
        persistSession(false) // DEMO
        state = .onboarding
    }
}
