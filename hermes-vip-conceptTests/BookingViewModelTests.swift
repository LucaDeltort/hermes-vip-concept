//
//  BookingViewModelTests.swift
//  hermes-vip-conceptTests
//
//

import XCTest
@testable import hermes_vip_concept

@MainActor
final class BookingViewModelTests: XCTestCase {

    private var booking: StubBookingRepository!

    override func setUp() {
        super.setUp()
        booking = StubBookingRepository()
    }

    override func tearDown() {
        booking = nil
        super.tearDown()
    }

    private func makeSUT() -> BookingScreen.ViewModel {
        BookingScreen.ViewModel(bookingRepository: booking)
    }

    // MARK: - Loading

    func testLoadDefaultSelectsFirstAvailableSlot() async {
        let slots = BookingSlot.samples()
        booking.slotsHandler = { _ in slots }

        let sut = makeSUT()
        await sut.load()

        let firstAvailable = slots.first(where: \.isAvailable)
        XCTAssertEqual(sut.state.data?.slots.count, slots.count)
        XCTAssertEqual(sut.selectedSlot, firstAvailable)
        XCTAssertEqual(
            sut.selectedDay,
            Calendar.maison.startOfDay(for: firstAvailable!.date)
        )
        XCTAssertTrue(sut.canConfirm)
    }

    func testLoadFailsIntoErrorState() async {
        booking.slotsHandler = { _ in throw RepositoryError.network }

        let sut = makeSUT()
        await sut.load()

        XCTAssertTrue(sut.state.isError)
        XCTAssertNil(sut.selectedSlot)
        XCTAssertFalse(sut.canConfirm)
    }

    // MARK: - Selection

    func testSelectIgnoresUnavailableSlot() async {
        let slots = BookingSlot.samples()
        booking.slotsHandler = { _ in slots }
        let sut = makeSUT()
        await sut.load()

        let taken = slots.first { !$0.isAvailable }!
        sut.select(taken)

        XCTAssertNotEqual(sut.selectedSlot, taken)
    }

    func testSelectDayClearsSlotFromAnotherDay() async {
        let slots = BookingSlot.samples()
        booking.slotsHandler = { _ in slots }
        let sut = makeSUT()
        await sut.load()
        XCTAssertNotNil(sut.selectedSlot)

        // Move to a day that holds none of the selected slot's time.
        let otherDay = slots[0].date.addingTimeInterval(2 * 24 * 60 * 60)
        sut.selectDay(otherDay)

        XCTAssertNil(sut.selectedSlot)
        XCTAssertEqual(sut.selectedDay, otherDay)
    }

    func testSelectDayKeepsSlotOnSameDay() async {
        let slots = BookingSlot.samples()
        booking.slotsHandler = { _ in slots }
        let sut = makeSUT()
        await sut.load()
        let selected = sut.selectedSlot

        sut.selectDay(selected!.date)

        XCTAssertEqual(sut.selectedSlot, selected)
    }

    // MARK: - Booking write-path

    func testBookSucceedsReturnsAppointment() async {
        booking.slotsHandler = { _ in BookingSlot.samples() }
        booking.bookHandler = { _ in .sample }
        let sut = makeSUT()
        await sut.load()

        let appointment = await sut.book()

        XCTAssertEqual(appointment, .sample)
        XCTAssertNil(sut.bookingError)
        XCTAssertFalse(sut.isBooking)
    }

    func testBookFailureSetsErrorAndReturnsNil() async {
        booking.slotsHandler = { _ in BookingSlot.samples() }
        booking.bookHandler = { _ in throw RepositoryError.network }
        let sut = makeSUT()
        await sut.load()

        let appointment = await sut.book()

        XCTAssertNil(appointment)
        XCTAssertNotNil(sut.bookingError)
        XCTAssertFalse(sut.isBooking)
    }

    func testBookWithoutSelectionReturnsNil() async {
        booking.slotsHandler = { _ in [] } // no slots -> nothing selected
        let sut = makeSUT()
        await sut.load()

        let appointment = await sut.book()

        XCTAssertNil(appointment)
    }
}
