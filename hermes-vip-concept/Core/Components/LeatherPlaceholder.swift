//
//  LeatherPlaceholder.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// A leather-gradient placeholder for product/editorial imagery.
struct LeatherPlaceholder: View {
    var cornerRadius: CGFloat = Theme.Radius.card
    /// Optional mono caption pinned to the bottom-left (e.g. "SAC · VEAU TOGO").
    /// When set, the sun emblem is hidden — matching the editorial image style.
    var label: String?

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "3A3128"), Color(hex: "211C16")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                HatchingPattern()
                    .stroke(Color(.hairline), lineWidth: Theme.Metrics.hairlineWidth)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .overlay(alignment: label == nil ? .center : .bottomLeading) {
                if let label {
                    Text(label.uppercased())
                        .font(Theme.Font.mono(9))
                        .tracking(Theme.Tracking.wide(9))
                        .foregroundStyle(Color(.textSecondary).opacity(0.5))
                        .padding(12)
                } else {
                    Image(systemName: "sun.max")
                        .font(.system(size: 22, weight: .ultraLight))
                        .foregroundStyle(Color(.gold).opacity(0.35))
                }
            }
    }
}

/// Diagonal hatching lines drawn across the bounds.
private struct HatchingPattern: Shape {
    var spacing: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var x = -rect.height
        while x < rect.width {
            path.move(to: CGPoint(x: x, y: rect.height))
            path.addLine(to: CGPoint(x: x + rect.height, y: 0))
            x += spacing
        }
        return path
    }
}

#Preview {
    LeatherPlaceholder()
        .frame(height: 220)
        .padding(Theme.Spacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
}
