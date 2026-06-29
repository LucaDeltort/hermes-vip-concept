//
//  ProfileRepository.swift
//  hermes-vip-concept
//
//

import Foundation

/// The member's profile and their personal advisor.
protocol ProfileRepository: Sendable {
    func profile() async throws -> MemberProfile
    func advisor() async throws -> Advisor
}
