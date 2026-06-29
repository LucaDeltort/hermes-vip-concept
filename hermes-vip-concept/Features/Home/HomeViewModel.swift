//
//  HomeViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension HomeScreen {
    /// The composed data the home screen renders.
    struct ViewData: Equatable {
        let memberName: String
        let nextAppointment: Appointment?
        let curated: [Product]
        let editorial: [EditorialMoment]
    }

    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let catalogRepository: CatalogRepository
        @ObservationIgnored private let bookingRepository: BookingRepository
        @ObservationIgnored private let profileRepository: ProfileRepository

        var state: AsyncUIState<ViewData> = .idle

        init(
            catalogRepository: CatalogRepository? = nil,
            bookingRepository: BookingRepository? = nil,
            profileRepository: ProfileRepository? = nil
        ) {
            self.catalogRepository = catalogRepository ?? AppContainer.shared.catalogRepository()
            self.bookingRepository = bookingRepository ?? AppContainer.shared.bookingRepository()
            self.profileRepository = profileRepository ?? AppContainer.shared.profileRepository()
        }

        /// Load the full home composition. Runs the three calls concurrently.
        func load() async {
            state = .loading
            do {
                async let profile = profileRepository.profile()
                async let appointment = bookingRepository.nextAppointment()
                async let curated = catalogRepository.curatedProducts()
                async let editorial = catalogRepository.editorialMoments()

                let data = try await ViewData(
                    memberName: profile.name,
                    nextAppointment: appointment,
                    curated: curated,
                    editorial: editorial
                )
                state = .data(data)
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }
    }
}
