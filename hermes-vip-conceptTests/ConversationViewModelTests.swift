//
//  ConversationViewModelTests.swift
//  hermes-vip-conceptTests
//
//

import XCTest
@testable import hermes_vip_concept

@MainActor
final class ConversationViewModelTests: XCTestCase {

    private var repository: StubConversationRepository!

    override func setUp() {
        super.setUp()
        repository = StubConversationRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    private func makeSUT() -> ConversationScreen.ViewModel {
        ConversationScreen.ViewModel(repository: repository)
    }

    // MARK: - Loading

    func testLoadSucceedsIntoDataState() async {
        repository.conversationHandler = { .sample }

        let sut = makeSUT()
        await sut.load()

        XCTAssertEqual(sut.state.data, .sample)
        XCTAssertFalse(sut.state.isError)
    }

    func testLoadFailsIntoErrorState() async {
        repository.conversationHandler = { throw RepositoryError.network }

        let sut = makeSUT()
        await sut.load()

        XCTAssertTrue(sut.state.isError)
        XCTAssertNil(sut.state.data)
    }

    // MARK: - canSend

    func testCanSendFalseForBlankDraft() {
        let sut = makeSUT()
        sut.draft = "   \n "
        XCTAssertFalse(sut.canSend)
    }

    func testCanSendTrueForNonEmptyDraft() {
        let sut = makeSUT()
        sut.draft = "Bonjour Élise"
        XCTAssertTrue(sut.canSend)
    }

    // MARK: - Sending

    func testSendClearsDraftAndUpdatesState() async {
        let updated = Conversation(id: "updated", advisor: .sample, messages: [])
        repository.sendHandler = { _ in updated }

        let sut = makeSUT()
        sut.draft = "  Une question  "
        await sut.send()

        XCTAssertEqual(sut.draft, "")
        XCTAssertEqual(sut.state.data, updated)
        XCTAssertFalse(sut.isSending)
    }

    func testSendForwardsTrimmedText() async {
        var received: String?
        repository.sendHandler = { text in
            received = text
            return .sample
        }

        let sut = makeSUT()
        sut.draft = "  Bonjour  "
        await sut.send()

        XCTAssertEqual(received, "Bonjour")
    }

    func testSendFailureRestoresDraft() async {
        repository.sendHandler = { _ in throw RepositoryError.network }

        let sut = makeSUT()
        sut.draft = "Mon message"
        await sut.send()

        XCTAssertEqual(sut.draft, "Mon message")
        XCTAssertFalse(sut.isSending)
    }

    func testSendIgnoresBlankDraft() async {
        var didCall = false
        repository.sendHandler = { _ in
            didCall = true
            return .sample
        }

        let sut = makeSUT()
        sut.draft = "   "
        await sut.send()

        XCTAssertFalse(didCall)
    }
}
