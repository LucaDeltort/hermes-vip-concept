//
//  InvitationScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct InvitationScreen: View {
    @Environment(\.appStateManager) private var appState
    @State private var viewModel = ViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // Logo + pulsing halo, centred near 34% of the screen height.
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 64)
                    .foregroundStyle(Color(.textPrimary))
                    .accessibilityLabel("Hermès Paris")
                    .background { GlowHalo().frame(width: 360, height: 360) }
                    .frame(maxWidth: .infinity)
                    .padding(.top, max(geo.size.height * 0.34 - 20, 0))

                // Code entry, pinned to the bottom.
                VStack(spacing: Theme.Spacing.sm) {
                    TextField(
                        "",
                        text: $viewModel.code,
                        prompt: Text("Code d'invitation")
                    )
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(Theme.Font.mono(14))
                        .tracking(14 * 0.18)
                        .foregroundStyle(Color(.textPrimary))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .frame(height: Theme.Metrics.buttonHeight)
                        .background(
                            Color(.inputSurface),
                            in: RoundedRectangle(cornerRadius: Theme.Radius.input)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.input)
                                .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
                        )

                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(Theme.Font.body(13))
                            .foregroundStyle(Color(.accent))
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await viewModel.submit { appState.advanceToWelcome() } }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(Color(.backgroundBase))
                        } else {
                            Text("Entrer")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.canSubmit))
                    .disabled(!viewModel.canSubmit)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
    }
}

// MARK: - Splash visuals

/// Pulsing radial halo behind the logo (`GlowHalo`: 7s opacity + scale loop).
private struct GlowHalo: View {
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(.accent).opacity(0.13), Color(.accent).opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180 * 0.62
                )
            )
            .opacity(pulse ? 0.85 : 0.55)
            .scaleEffect(pulse ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

#Preview {
    InvitationScreen()
        .environment(\.appStateManager, AppStateManager())
}
