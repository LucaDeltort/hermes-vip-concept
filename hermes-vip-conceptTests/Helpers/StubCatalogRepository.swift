//
//  StubCatalogRepository.swift
//  hermes-vip-conceptTests
//
//

import Foundation
@testable import hermes_vip_concept

final class StubCatalogRepository: CatalogRepository, @unchecked Sendable {
    var curatedHandler: (() async throws -> [Product])?
    var editorialHandler: (() async throws -> [EditorialMoment])?
    var productHandler: ((String) async throws -> Product)?
    var wishlistHandler: (() async throws -> [Product])?
    var ownedHandler: (() async throws -> [OwnedPiece])?
    var toggleHandler: ((String) async throws -> Product)?

    func curatedProducts() async throws -> [Product] {
        guard let curatedHandler else { return Product.samples }
        return try await curatedHandler()
    }

    func editorialMoments() async throws -> [EditorialMoment] {
        guard let editorialHandler else { return EditorialMoment.samples }
        return try await editorialHandler()
    }

    func product(id: String) async throws -> Product {
        guard let productHandler else { return .sample }
        return try await productHandler(id)
    }

    func wishlist() async throws -> [Product] {
        guard let wishlistHandler else { return Product.samples.filter(\.isFavorite) }
        return try await wishlistHandler()
    }

    func ownedPieces() async throws -> [OwnedPiece] {
        guard let ownedHandler else { return OwnedPiece.samples }
        return try await ownedHandler()
    }

    func toggleFavorite(productID: String) async throws -> Product {
        guard let toggleHandler else { return .sample }
        return try await toggleHandler(productID)
    }
}
