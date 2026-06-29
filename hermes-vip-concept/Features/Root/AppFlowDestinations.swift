//
//  AppFlowDestinations.swift
//  hermes-vip-concept
//
//

import SwiftUI

private struct AppFlowDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .productDetail(let productID):
                ProductDetailScreen(productID: productID)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

extension View {
    /// Register the product/events destinations on the enclosing `NavigationStack`.
    func appFlowDestinations() -> some View {
        modifier(AppFlowDestinations())
    }

    /// Smoothly hides the tab bar when the navigation path is non-empty,
    /// and animates its reappearance when returning to the root.
    func tabBarVisibility(isPathEmpty: Bool) -> some View {
        self
            .toolbar(isPathEmpty ? .visible : .hidden, for: .tabBar)
            .animation(.easeInOut(duration: 0.25), value: isPathEmpty)
    }
}
