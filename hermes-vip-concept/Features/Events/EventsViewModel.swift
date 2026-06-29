//
//  EventsViewModel.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension EventsScreen {
    /// Everything the Events screen renders: upcoming events + past souvenirs.
    struct ViewData: Equatable {
        var events: [Event]
        var souvenirs: [Souvenir]
    }

    @MainActor
    @Observable
    final class ViewModel {
        @ObservationIgnored private let repository: EventsRepository

        var state: AsyncUIState<ViewData> = .idle

        init(repository: EventsRepository? = nil) {
            self.repository = repository ?? AppContainer.shared.eventsRepository()
        }

        func load() async {
            state = .loading
            do {
                async let events = repository.events()
                async let souvenirs = repository.souvenirs()
                state = .data(ViewData(events: try await events, souvenirs: try await souvenirs))
            } catch let error as RepositoryError {
                state = .error(LocalizedStringKey(error.localizedDescription))
            } catch {
                state = .error("Une erreur est survenue.")
            }
        }
    }
}
