//
//  PlaceholderScreen.swift
//  hermes-vip-concept
//
//

import SwiftUI

struct PlaceholderScreen: View {
    let eyebrow: String
    let title: String
    var note: String = "Écran à venir."

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Spacer()
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .foregroundStyle(Color(.textPrimary))
                .accessibilityLabel("Hermès Paris")
            EyebrowLabel(text: eyebrow)
            Text(title)
                .font(Theme.Font.display(28, weight: .light))
                .foregroundStyle(Color(.textPrimary))
            Text(note)
                .font(Theme.Font.body(14))
                .foregroundStyle(Color(.textMuted))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
    }
}

#Preview {
    PlaceholderScreen(eyebrow: "Conversation", title: "Élise Vaubourg")
}
