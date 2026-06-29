//
//  CatalogRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// Curated products, editorial moments, the member's wishlist and owned pieces.
protocol CatalogRepository: Sendable {
    func curatedProducts() async throws -> [Product]
    func editorialMoments() async throws -> [EditorialMoment]
    func product(id: String) async throws -> Product
    func wishlist() async throws -> [Product]
    func ownedPieces() async throws -> [OwnedPiece]
    func toggleFavorite(productID: String) async throws -> Product
}

extension Notification.Name {
    /// Posted when a product's favorite state changes, so other tabs can refresh.
    static let catalogFavoritesDidChange = Notification.Name("catalogFavoritesDidChange")
}
