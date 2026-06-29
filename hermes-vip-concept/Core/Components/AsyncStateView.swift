//
//  AsyncStateView.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// Drives a screen body from an `AsyncUIState`.
///
/// ```swift
/// AsyncStateView(state: viewModel.state) { data in
///     HomeContent(data: data)
/// }
/// ```
struct AsyncStateView<ViewData: Equatable, DataContent: View>: View {
    let state: AsyncUIState<ViewData>
    /// Optional sample used to render a redacted skeleton while loading.
    var skeletonData: ViewData?
    var onRetry: (() -> Void)?
    @ViewBuilder let dataContent: (ViewData) -> DataContent

    var body: some View {
        switch state {
        case .idle:
            Color.clear

        case .loading:
            if let skeletonData {
                dataContent(skeletonData)
                    .redacted(reason: .placeholder)
                    .allowsHitTesting(false)
            } else {
                ProgressView()
                    .tint(Color(.gold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

        case .data(let data):
            dataContent(data)

        case .error(let message):
            ErrorStateView(message: message, onRetry: onRetry)
        }
    }
}

/// The default error layout (centered, with optional "Réessayer").
struct ErrorStateView: View {
    let message: LocalizedStringKey
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(Color(.gold))
            Text(message)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)
            if let onRetry {
                Button("Réessayer", action: onRetry)
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(maxWidth: 200)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Error") {
    ErrorStateView(message: "La connexion à la maison a échoué.") {}
        .hermesBackground()
}
