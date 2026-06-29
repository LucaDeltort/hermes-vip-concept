//
//  EyebrowLabel.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// A small uppercase mono "eyebrow" label (e.g. "SUR INVITATION").
struct EyebrowLabel: View {
    let text: String
    var color: Color = Color(.gold)
    var size: CGFloat = 11

    var body: some View {
        Text(text.uppercased())
            .font(Theme.Font.mono(size, weight: .medium))
            .tracking(Theme.Tracking.wider(size))
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(spacing: 16) {
        EyebrowLabel(text: "L'Atelier")
        EyebrowLabel(text: "Sur invitation", color: Color(.textMuted))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .hermesBackground()
}
