//
//  Chip.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// A tappable chip (e.g. a booking time slot).
struct Chip: View {
    let title: String
    var isSelected: Bool = false
    var isEnabled: Bool = true

    var body: some View {
        Text(title)
            .font(Theme.Font.mono(13, weight: .medium))
            .tracking(Theme.Tracking.wide(13))
            .foregroundStyle(foreground)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(background, in: RoundedRectangle(cornerRadius: Theme.Radius.chip))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.chip)
                    .strokeBorder(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
            )
            .opacity(isEnabled ? 1 : 0.35)
    }

    private var foreground: Color {
        isSelected ? Color(.backgroundBase) : Color(.textPrimary)
    }

    private var background: Color {
        isSelected ? Color(.accent) : Color(.inputSurface)
    }
}

#Preview {
    HStack {
        Chip(title: "10:00")
        Chip(title: "14:00", isSelected: true)
        Chip(title: "15:00", isEnabled: false)
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .hermesBackground()
}
