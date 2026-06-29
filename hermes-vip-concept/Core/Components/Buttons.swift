//
//  Buttons.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// Full-width accent-filled pill with a dark label. The primary CTA.
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.mono(13, weight: .medium))
            .tracking(Theme.Tracking.wide(13))
            .foregroundStyle(Color(.backgroundBase))
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Metrics.buttonHeight)
            .background(
                Color(.accent).opacity(isEnabled ? 1 : 0.35),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Transparent pill with a muted 1px border and light label.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.mono(13, weight: .medium))
            .tracking(Theme.Tracking.wide(13))
            .foregroundStyle(Color(.textPrimary))
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Metrics.buttonHeight)
            .overlay(
                Capsule().strokeBorder(Color(.textMuted), lineWidth: Theme.Metrics.borderWidth)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Wishlist toggle: accent-filled pill to add, outlined pill once favorited.
struct FavoriteToggleButtonStyle: ButtonStyle {
    var isFavorite: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Font.mono(13, weight: .medium))
            .tracking(Theme.Tracking.wide(13))
            .foregroundStyle(isFavorite ? Color(.textPrimary) : Color(.backgroundBase))
            .frame(maxWidth: .infinity)
            .frame(height: Theme.Metrics.buttonHeight)
            .background(isFavorite ? Color.clear : Color(.accent), in: Capsule())
            .overlay(
                Capsule().strokeBorder(
                    isFavorite ? Color(.textMuted) : .clear,
                    lineWidth: Theme.Metrics.borderWidth
                )
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("Entrer dans la maison") {}
            .buttonStyle(PrimaryButtonStyle())
        Button("Plus tard") {}
            .buttonStyle(SecondaryButtonStyle())
        Button("Ajouter à ma wishlist") {}
            .buttonStyle(FavoriteToggleButtonStyle(isFavorite: false))
        Button("Retirer de ma wishlist") {}
            .buttonStyle(FavoriteToggleButtonStyle(isFavorite: true))
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .hermesBackground()
}
