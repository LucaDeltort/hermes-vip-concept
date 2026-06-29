//
//  PiecesViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension PiecesScreen {
    /// The two lists backing the Collection tab's segmented control.
    struct ViewData: Equatable {
        let wishlist: [Product]
        let owned: [OwnedPiece]
    }

    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let catalogRepository: CatalogRepository

        var state: AsyncUIState<ViewData> = .idle

        init(catalogRepository: CatalogRepository? = nil) {
            self.catalogRepository = catalogRepository ?? AppContainer.shared.catalogRepository()
        }

        func load() async {
            // Keep prior content visible while refreshing; only show the skeleton
            // on the first load.
            if state.data == nil { state = .loading }
            do {
                async let wishlist = catalogRepository.wishlist()
                async let owned = catalogRepository.ownedPieces()
                state = try await .data(ViewData(wishlist: wishlist, owned: owned))
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }
    }
}
