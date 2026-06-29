//
//  DTOMappingTests.swift
//  hermes-vip-conceptTests
//
//

import XCTest
@testable import hermes_vip_concept

final class DTOMappingTests: XCTestCase {

    func testProductDTOMapsToEntity() {
        let dto = ProductDTO(
            id: "p1", name: "Birkin", category: "Maroquinerie",
            material: "Cuir", color: "Étoupe", description: "desc", advisorNote: "note",
            badge: nil, imageAssets: ["a"], isFavorite: true
        )
        let entity = dto.toEntity
        XCTAssertEqual(entity.id, "p1")
        XCTAssertEqual(entity.name, "Birkin")
        XCTAssertTrue(entity.isFavorite)
        XCTAssertEqual(entity.advisorNote, "note")
    }

    func testProductDTODefaultsNilFields() {
        let dto = ProductDTO(
            id: nil, name: nil, category: nil,
            material: nil, color: nil, description: nil, advisorNote: nil,
            badge: nil, imageAssets: nil, isFavorite: nil
        )
        let entity = dto.toEntity
        XCTAssertFalse(entity.id.isEmpty)      // stable "unknown-" fallback id
        XCTAssertEqual(entity.name, "")
        XCTAssertEqual(entity.imageAssets, [])
        XCTAssertFalse(entity.isFavorite)
        XCTAssertNil(entity.advisorNote)
    }

    func testOwnedPieceDTOMapsToEntity() {
        let dto = OwnedPieceDTO(
            id: "o1", name: "Kelly 28", category: "Maroquinerie",
            material: "Cuir", color: "Noir", year: 2021, imageAssets: ["a"]
        )
        let entity = dto.toEntity
        XCTAssertEqual(entity.id, "o1")
        XCTAssertEqual(entity.name, "Kelly 28")
        XCTAssertEqual(entity.category, "Maroquinerie")
        XCTAssertEqual(entity.imageAssets, ["a"])
    }

    func testInvitationDTOMapping() {
        let dto = InvitationCodeDTO(id: "i1", code: "HERMES", valid: true, memberName: "Camille")
        let entity = dto.toEntity
        XCTAssertTrue(entity.isValid)
        XCTAssertEqual(entity.memberName, "Camille")
    }

    func testMessageDTOSenderFallsBackToAdvisor() {
        let dto = MessageDTO(id: "m1", sender: "garbage", text: "hi", timestamp: Date())
        XCTAssertEqual(dto.toEntity.sender, .advisor)
    }
}
