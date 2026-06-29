//
//  BackgroundGradient.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// The warm near-black radial background used app-wide: a soft halo at center
/// (`#1c1813`) falling off to a darker edge (`#100E0C`), matching the mockup.
struct BackgroundGradient: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            RadialGradient(
                colors: [Color(hex: "1C1813"), Color(hex: "100E0C")],
                center: .center,
                startRadius: 0,
                // Reach the farthest corner so the falloff fills the screen.
                endRadius: hypot(size.width, size.height) / 2
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Place the maison background behind this view.
    func hermesBackground() -> some View {
        background(BackgroundGradient())
    }
}

#Preview {
    Text("HERMÈS PARIS")
        .font(Theme.Font.display(28, weight: .light))
        .foregroundStyle(Color(.textPrimary))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .hermesBackground()
}
