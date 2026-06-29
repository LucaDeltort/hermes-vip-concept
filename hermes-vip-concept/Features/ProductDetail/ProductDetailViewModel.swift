//
//  ProductDetailViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension ProductDetailScreen {
    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let catalogRepository: CatalogRepository
        @ObservationIgnored let productID: String

        var state: AsyncUIState<Product> = .idle
        /// True while a favorite-toggle request is in flight.
        var isTogglingFavorite = false

        init(productID: String, catalogRepository: CatalogRepository? = nil) {
            self.productID = productID
            self.catalogRepository = catalogRepository ?? AppContainer.shared.catalogRepository()
        }

        func load() async {
            state = .loading
            do {
                let product = try await catalogRepository.product(id: productID)
                state = .data(product)
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }

        /// Toggle favorite membership.
        func toggleFavorite() async {
            guard let current = state.data, !isTogglingFavorite else { return }
            isTogglingFavorite = true
            defer { isTogglingFavorite = false }
            do {
                let updated = try await catalogRepository.toggleFavorite(productID: current.id)
                state = .data(updated)
            } catch {
                // Keep the current state; a transient failure shouldn't disrupt the page.
            }
        }
    }
}
