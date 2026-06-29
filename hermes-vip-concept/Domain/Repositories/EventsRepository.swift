//
//  EventsRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// Private maison events and photo souvenirs.
protocol EventsRepository: Sendable {
    func events() async throws -> [Event]
    func souvenirs() async throws -> [Souvenir]
}
