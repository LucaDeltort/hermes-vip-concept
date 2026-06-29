//
//  AppContainer.swift
//  hermes-vip-concept
//
//

import Foundation

@MainActor
final class AppContainer {
    /// Shared composition root.
    static let shared = AppContainer()

    private init() {}

    // MARK: - Transport

    lazy var apiClient: Factory<APIClient> = Factory { MockAPIClient() }.singleton()

    // MARK: - Repositories

    lazy var invitationRepository: Factory<InvitationRepository> = Factory {
        APIInvitationRepository(client: self.apiClient())
    }

    lazy var catalogRepository: Factory<CatalogRepository> = Factory {
        APICatalogRepository(client: self.apiClient())
    }

    lazy var bookingRepository: Factory<BookingRepository> = Factory {
        APIBookingRepository(client: self.apiClient())
    }

    lazy var conversationRepository: Factory<ConversationRepository> = Factory {
        APIConversationRepository(client: self.apiClient())
    }

    lazy var eventsRepository: Factory<EventsRepository> = Factory {
        APIEventsRepository(client: self.apiClient())
    }

    lazy var profileRepository: Factory<ProfileRepository> = Factory {
        APIProfileRepository(client: self.apiClient())
    }

    // MARK: - Managers

    lazy var appState: Factory<AppStateManager> = Factory { AppStateManager() }.singleton()
}
