//
//  StubRepositories.swift
//  hermes-vip-conceptTests
//
//

import Foundation
@testable import hermes_vip_concept

final class StubBookingRepository: BookingRepository, @unchecked Sendable {
    var nextHandler: (() async throws -> Appointment?)?
    var slotsHandler: ((Date) async throws -> [BookingSlot])?
    var bookHandler: ((BookingSlot) async throws -> Appointment)?
    var cancelHandler: ((Appointment) async throws -> Void)?

    func nextAppointment() async throws -> Appointment? {
        guard let nextHandler else { return .sample }
        return try await nextHandler()
    }

    func availableSlots(forMonth month: Date) async throws -> [BookingSlot] {
        guard let slotsHandler else { return BookingSlot.samples() }
        return try await slotsHandler(month)
    }

    func book(slot: BookingSlot) async throws -> Appointment {
        guard let bookHandler else { return .sample }
        return try await bookHandler(slot)
    }

    func cancel(appointment: Appointment) async throws {
        try await cancelHandler?(appointment)
    }
}

final class StubProfileRepository: ProfileRepository, @unchecked Sendable {
    var profileHandler: (() async throws -> MemberProfile)?
    var advisorHandler: (() async throws -> Advisor)?

    func profile() async throws -> MemberProfile {
        guard let profileHandler else { return .sample }
        return try await profileHandler()
    }

    func advisor() async throws -> Advisor {
        guard let advisorHandler else { return .sample }
        return try await advisorHandler()
    }
}

final class StubConversationRepository: ConversationRepository, @unchecked Sendable {
    var conversationHandler: (() async throws -> Conversation)?
    var sendHandler: ((String) async throws -> Conversation)?

    func conversation() async throws -> Conversation {
        guard let conversationHandler else { return .sample }
        return try await conversationHandler()
    }

    func send(text: String) async throws -> Conversation {
        guard let sendHandler else { return .sample }
        return try await sendHandler(text)
    }
}

final class StubInvitationRepository: InvitationRepository, @unchecked Sendable {
    var validateHandler: ((String) async throws -> InvitationCode)?

    func validate(code: String) async throws -> InvitationCode {
        guard let validateHandler else { return .sample }
        return try await validateHandler(code)
    }
}
