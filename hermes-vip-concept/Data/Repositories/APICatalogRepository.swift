//
//  APICatalogRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// `CatalogRepository` backed by an `APIClient`.
struct APICatalogRepository: CatalogRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func curatedProducts() async throws -> [Product] {
        try await mappingAPIErrors {
            let dtos: [ProductDTO] = try await client.request(Endpoint.Catalog.curated())
            return dtos.map(\.toEntity)
        }
    }

    func editorialMoments() async throws -> [EditorialMoment] {
        try await mappingAPIErrors {
            let dtos: [EditorialMomentDTO] = try await client.request(Endpoint.Catalog.editorial())
            return dtos.map(\.toEntity)
        }
    }

    func product(id: String) async throws -> Product {
        try await mappingAPIErrors {
            let dto: ProductDTO = try await client.request(Endpoint.Catalog.product(id: id))
            return dto.toEntity
        }
    }

    func wishlist() async throws -> [Product] {
        try await mappingAPIErrors {
            let dtos: [ProductDTO] = try await client.request(Endpoint.Catalog.wishlist())
            return dtos.map(\.toEntity)
        }
    }

    func ownedPieces() async throws -> [OwnedPiece] {
        try await mappingAPIErrors {
            let dtos: [OwnedPieceDTO] = try await client.request(Endpoint.Catalog.owned())
            return dtos.map(\.toEntity)
        }
    }

    func toggleFavorite(productID: String) async throws -> Product {
        try await mappingAPIErrors {
            let dto: ProductDTO = try await client.request(
                Endpoint.Catalog.toggleFavorite(id: productID)
            )
            await MainActor.run {
                NotificationCenter.default.post(name: .catalogFavoritesDidChange, object: nil)
            }
            return dto.toEntity
        }
    }
}
