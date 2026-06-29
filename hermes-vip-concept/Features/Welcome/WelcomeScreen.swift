//
//  WelcomeScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(\.appStateManager) private var appState
    @State private var viewModel: ViewModel
    /// Drives the staggered editorial reveal once the profile is loaded.
    @State private var revealed = false

    init(viewModel: ViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? ViewModel())
    }

    /// Horizontal screen inset for this onboarding screen (matches the mockup).
    private let inset: CGFloat = 40

    var body: some View {
        AsyncStateView(
            state: viewModel.state,
            skeletonData: .sample,
            onRetry: { Task { await viewModel.load() } }
        ) { profile in
            content(profile)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
        .safeAreaInset(edge: .bottom) {
            if viewModel.state.data != nil {
                Button("Découvrir") { appState.didCompleteOnboarding() }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, inset)
                    .padding(.bottom, Theme.Spacing.xs)
                    .reveal(revealed, index: 4)
            }
        }
        .task {
            if viewModel.state.data == nil { await viewModel.load() }
        }
        .onChange(of: viewModel.state.data != nil) { _, hasData in
            if hasData { revealed = true }
        }
        .onAppear { if viewModel.state.data != nil { revealed = true } }
    }

    private func content(_ profile: MemberProfile) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)

            EyebrowLabel(text: "Bienvenue", color: Color(.textMuted))
                .padding(.bottom, 26)
                .reveal(revealed, index: 0)

            Text("Bienvenue\n\(profile.name)")
                .font(Theme.Font.display(42))
                .tracking(-0.5)
                .lineSpacing(4)
                .foregroundStyle(Color(.textPrimary))
                .reveal(revealed, index: 1)

            if let advisor = profile.advisor {
                advisorIntro(advisor)
                    .padding(.top, 58)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, inset)
    }

    private func advisorIntro(_ advisor: Advisor) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 18) {
                ProductImageView(
                    assets: [advisor.portraitAsset].compactMap { $0 },
                    cornerRadius: 33
                )
                .frame(width: 66, height: 66)
                .overlay(
                    Circle().strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(advisor.name)
                        .font(Theme.Font.display(22))
                        .foregroundStyle(Color(.textPrimary))
                    Text(advisor.boutique.uppercased())
                        .font(Theme.Font.mono(10.5))
                        .tracking(10.5 * 0.20)
                        .foregroundStyle(Color(.textSecondary))
                }

                Spacer(minLength: 0)
            }
            .reveal(revealed, index: 2)

            Text(advisor.introduction)
                .font(Theme.Font.displayItalic(16, weight: .light))
                .lineSpacing(6)
                .foregroundStyle(Color(.textSecondary))
                .frame(maxWidth: 290, alignment: .leading)
                .reveal(revealed, index: 3)
        }
    }
}

/// Staggered "rise + fade" entrance used by the welcome screen's editorial blocks.
private extension View {
    func reveal(_ revealed: Bool, index: Int) -> some View {
        self
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 20)
            .animation(
                .easeOut(duration: 0.7).delay(0.15 + Double(index) * 0.11),
                value: revealed
            )
    }
}

#Preview {
    WelcomeScreen(
        viewModel: WelcomeScreen.ViewModel(
            repository: APIProfileRepository(client: MockAPIClient())
        )
    )
    .environment(\.appStateManager, AppStateManager())
    .preferredColorScheme(.dark)
}
