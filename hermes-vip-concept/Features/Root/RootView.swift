//
//  RootView.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct RootView: View {
    @Environment(AppStateManager.self) private var appState

    var body: some View {
        ZStack {
            switch appState.state {
            case .splash:
                SplashView()
            case .onboarding:
                InvitationScreen()
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(with: .scale(scale: 0.98))
                    ))
            case .welcome:
                WelcomeScreen()
                    .transition(.opacity)
            case .locked:
                LockScreen()
                    .transition(.opacity)
            case .authenticated:
                RootTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: appState.state)
    }
}

/// Brief sun-emblem splash that auto-advances into onboarding.
private struct SplashView: View {
    @Environment(AppStateManager.self) private var appState
    @State private var glow = false

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(height: 56)
                .foregroundStyle(Color(.textPrimary))
                .shadow(color: Color(.gold).opacity(glow ? 0.6 : 0.1), radius: glow ? 30 : 8)
                .scaleEffect(glow ? 1.05 : 0.95)
                .accessibilityLabel("Hermès Paris")
            EyebrowLabel(text: "Cercle VIP")
                .opacity(glow ? 1 : 0.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            appState.resumeFromSplash()
        }
    }
}

/// Shown when a persisted session is gated behind Face ID / Touch ID. Prompts
/// automatically on appear; offers a manual retry and an escape (sign out).
private struct LockScreen: View {
    @Environment(AppStateManager.self) private var appState
    @State private var isAuthenticating = false

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .foregroundStyle(Color(.textPrimary))
                .accessibilityLabel("Hermès Paris")
            EyebrowLabel(text: "Cercle VIP")
            Spacer()

            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: "faceid")
                    .font(.system(size: 34, weight: .ultraLight))
                    .foregroundStyle(Color(.gold))
                Text("Votre espace est verrouillé")
                    .font(Theme.Font.display(20, weight: .light))
                    .foregroundStyle(Color(.textPrimary))

                Button("Déverrouiller avec \(BiometricAuthenticator.biometryLabel)") {
                    Task { await authenticate() }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isAuthenticating)

                Button("Se déconnecter") { appState.signOut() }
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(Theme.Spacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
        .task { await authenticate() }
    }

    private func authenticate() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        await appState.unlock()
        isAuthenticating = false
    }
}

#Preview("Authenticated") {
    let manager = AppStateManager()
    manager.didCompleteOnboarding()
    return RootView()
        .environment(manager)
        .environment(\.appStateManager, manager)
        .preferredColorScheme(.dark)
}
