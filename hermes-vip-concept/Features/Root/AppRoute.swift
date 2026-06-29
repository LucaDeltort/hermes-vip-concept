//
//  AppRoute.swift
//  hermes-vip-concept
//
//

import Foundation

/// A pushable destination inside a `NavigationStack`. Carries the minimal
/// payload each screen needs; the screens load their own full data via repos.
enum AppRoute: Hashable {
    /// Screen 4 — product detail, loaded by id.
    case productDetail(productID: String)
}
