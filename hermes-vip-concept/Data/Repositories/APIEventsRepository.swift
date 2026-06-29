//
//  APIEventsRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// `EventsRepository` backed by an `APIClient`.
struct APIEventsRepository: EventsRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func events() async throws -> [Event] {
        try await mappingAPIErrors {
            let dtos: [EventDTO] = try await client.request(Endpoint.Events.list())
            return dtos.map(\.toEntity)
        }
    }

    func souvenirs() async throws -> [Souvenir] {
        try await mappingAPIErrors {
            let dtos: [SouvenirDTO] = try await client.request(Endpoint.Events.souvenirs())
            return dtos.map(\.toEntity)
        }
    }
}
