//
//  ProductBadgeTag.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// A gold-tinted uppercase mono badge pill for `ProductBadge`.
struct ProductBadgeTag: View {
    let badge: ProductBadge

    var body: some View {
        Text(badge.label.uppercased())
            .font(Theme.Font.mono(9, weight: .medium))
            .tracking(Theme.Tracking.wide(9))
            .foregroundStyle(Color(.gold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.backgroundBase).opacity(0.7), in: Capsule())
            .overlay(
                Capsule().stroke(Color(.gold).opacity(0.5), lineWidth: Theme.Metrics.hairlineWidth)
            )
    }
}

#Preview {
    ProductBadgeTag(badge: .preview)
        .padding(Theme.Spacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
}
