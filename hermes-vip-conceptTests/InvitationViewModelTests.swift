//
//  InvitationViewModelTests.swift
//  hermes-vip-conceptTests
//
//

import XCTest
@testable import hermes_vip_concept

@MainActor
final class InvitationViewModelTests: XCTestCase {

    private var repository: StubInvitationRepository!

    override func setUp() {
        super.setUp()
        repository = StubInvitationRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    func testValidCodeInvokesSuccess() async {
        repository.validateHandler = { code in
            InvitationCode(id: "1", code: code, isValid: true, memberName: "Camille")
        }
        let sut = InvitationScreen.ViewModel(repository: repository)
        sut.code = "HERMES"

        var didSucceed = false
        await sut.submit { didSucceed = true }

        XCTAssertTrue(didSucceed)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func testRejectedCodeSetsErrorMessage() async {
        repository.validateHandler = { code in
            InvitationCode(id: "1", code: code, isValid: false, memberName: "")
        }
        let sut = InvitationScreen.ViewModel(repository: repository)
        sut.code = "WRONG"

        var didSucceed = false
        await sut.submit { didSucceed = true }

        XCTAssertFalse(didSucceed)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testNetworkErrorSetsErrorMessage() async {
        repository.validateHandler = { _ in throw RepositoryError.network }
        let sut = InvitationScreen.ViewModel(repository: repository)
        sut.code = "HERMES"

        await sut.submit {}

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
}
