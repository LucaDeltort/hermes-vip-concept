//
//  BiometricAuthenticator.swift
//  hermes-vip-concept
//
//

import LocalAuthentication

enum BiometricAuthenticator {
    /// Whether the device can evaluate biometrics (Face ID / Touch ID enrolled).
    static func canEvaluate() -> Bool {
        var error: NSError?
        return LAContext().canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics, error: &error
        )
    }

    /// Display name of the available biometry, for UI labels.
    static var biometryLabel: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Face ID"
        }
    }

    /// Prompts for Face ID / Touch ID. Returns `true` on success, `false` on
    /// cancel, failure, or when biometrics are unavailable.
    static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Annuler"
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            return false
        }
    }
}
