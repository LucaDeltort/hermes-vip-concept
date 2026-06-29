//
//  ProfileViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension ProfileScreen {
    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let repository: ProfileRepository

        var state: AsyncUIState<MemberProfile> = .idle

        init(repository: ProfileRepository? = nil) {
            self.repository = repository ?? AppContainer.shared.profileRepository()
        }

        func load() async {
            state = .loading
            do {
                let profile = try await repository.profile()
                state = .data(profile)
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }
    }
}
