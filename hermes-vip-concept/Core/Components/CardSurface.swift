//
//  CardSurface.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// Wrap content in the maison card surface.
struct CardSurface<Content: View>: View {
    var padding: CGFloat = Theme.Spacing.md
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Color(.card), in: RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
            )
    }
}

extension View {
    /// Place this view on the standard card surface.
    func cardSurface(padding: CGFloat = Theme.Spacing.md) -> some View {
        CardSurface(padding: padding) { self }
    }
}

#Preview {
    VStack {
        VStack(alignment: .leading, spacing: 8) {
            EyebrowLabel(text: "Maroquinerie")
            Text("Sac Birkin 30")
                .font(Theme.Font.display(22, weight: .regular))
                .foregroundStyle(Color(.textPrimary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .hermesBackground()
}
