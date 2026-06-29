//
//  HomeViewModelTests.swift
//  hermes-vip-conceptTests
//
//

import XCTest
@testable import hermes_vip_concept

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var catalog: StubCatalogRepository!
    private var booking: StubBookingRepository!
    private var profile: StubProfileRepository!

    override func setUp() {
        super.setUp()
        catalog = StubCatalogRepository()
        booking = StubBookingRepository()
        profile = StubProfileRepository()
    }

    override func tearDown() {
        catalog = nil
        booking = nil
        profile = nil
        super.tearDown()
    }

    private func makeSUT() -> HomeScreen.ViewModel {
        HomeScreen.ViewModel(
            catalogRepository: catalog,
            bookingRepository: booking,
            profileRepository: profile
        )
    }

    func testLoadSucceedsIntoDataState() async {
        profile.profileHandler = { .sample }
        booking.nextHandler = { .sample }
        catalog.curatedHandler = { Product.samples }
        catalog.editorialHandler = { EditorialMoment.samples }

        let sut = makeSUT()
        await sut.load()

        XCTAssertEqual(sut.state.data?.memberName, MemberProfile.sample.name)
        XCTAssertEqual(sut.state.data?.curated.count, Product.samples.count)
        XCTAssertFalse(sut.state.isError)
    }

    func testLoadFailsIntoErrorState() async {
        profile.profileHandler = { throw RepositoryError.network }

        let sut = makeSUT()
        await sut.load()

        XCTAssertTrue(sut.state.isError)
        XCTAssertNil(sut.state.data)
    }
}
