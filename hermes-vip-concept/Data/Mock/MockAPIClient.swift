//
//  MockAPIClient.swift
//  hermes-vip-concept
//
//

import Foundation

/// Backing mutable state for the mock server, isolated as an actor.
actor MockStore {
    private var favoriteProductIDs: Set<String>
    private var sentMessages: [MessageDTO] = []
    /// The visit booked this session, surfaced as the home's "prochain rendez-vous".
    private var bookedAppointment: AppointmentDTO?
    /// Set once the member cancels their visit, so `booking/next` returns none.
    private var appointmentCancelled = false

    init() {
        // Seed favorite state from the entity samples flagged `isFavorite`.
        favoriteProductIDs = Set(Product.samples.filter(\.isFavorite).map(\.id))
    }

    func isFavorite(_ id: String) -> Bool { favoriteProductIDs.contains(id) }

    func toggleFavorite(_ id: String) -> Bool {
        if favoriteProductIDs.contains(id) {
            favoriteProductIDs.remove(id)
            return false
        } else {
            favoriteProductIDs.insert(id)
            return true
        }
    }

    func favoriteIDs() -> Set<String> { favoriteProductIDs }

    func appendMessage(_ message: MessageDTO) { sentMessages.append(message) }
    func extraMessages() -> [MessageDTO] { sentMessages }

    func setBookedAppointment(_ dto: AppointmentDTO) {
        bookedAppointment = dto
        // Booking revives the appointment if it was previously cancelled.
        appointmentCancelled = false
    }

    func currentBooking() -> AppointmentDTO? { bookedAppointment }

    func cancelAppointment() {
        appointmentCancelled = true
        bookedAppointment = nil
    }
    func isAppointmentCancelled() -> Bool { appointmentCancelled }
}

/// The mock transport.
final class MockAPIClient: APIClient {
    private let bundle: Bundle
    private let store: MockStore
    private let latencyRange: ClosedRange<Double>
    private let failureRate: Double

    init(
        bundle: Bundle = .main,
        store: MockStore = MockStore(),
        latencyRange: ClosedRange<Double> = APIConfig.Mock.latencyRange,
        failureRate: Double = APIConfig.Mock.failureRate
    ) {
        self.bundle = bundle
        self.store = store
        self.latencyRange = latencyRange
        self.failureRate = failureRate
    }

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        try await simulateNetwork()

        let data = try await payload(for: endpoint)
        do {
            return try JSONDecoder.api.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    // MARK: - Network simulation

    private func simulateNetwork() async throws {
        let latency = Double.random(in: latencyRange)
        try? await Task.sleep(for: .seconds(latency))

        if failureRate > 0, Double.random(in: 0...1) < failureRate {
            throw APIError.transport
        }
    }

    // MARK: - Routing

    /// Resolve the raw JSON for an endpoint. Mutating endpoints update the store
    /// and synthesise a response; read endpoints serve a fixture.
    private func payload(for endpoint: Endpoint) async throws -> Data {
        switch (endpoint.method, endpoint.path) {
        case (.post, "invitation/validate"):
            return try MockResponses.invitationValidate(body: endpoint.body)

        case (.get, "catalog/curated"):
            return try await catalogCurated()
        case (.get, "catalog/editorial"):
            return try fixture("editorial")
        case (.get, "catalog/wishlist"):
            return try await catalogWishlist()
        case (.get, "catalog/owned"):
            return try JSONEncoder.api.encode(MockResponses.ownedPieces())
        case (.put, let path) where path.hasPrefix("catalog/products/") && path.hasSuffix("/favorite"):
            return try await toggleFavorite(productPath: path)
        case (.get, let path) where path.hasPrefix("catalog/products/"):
            return try await product(path: path)

        case (.get, "booking/next"):
            return try await nextAppointment()
        case (.get, "booking/slots"):
            return try MockResponses.bookingSlots()
        case (.post, "booking/reserve"):
            return try await reserve(body: endpoint.body)
        case (.delete, let path) where path.hasPrefix("booking/appointments/"):
            await store.cancelAppointment()
            return Data("{}".utf8)

        case (.get, "conversation"):
            return try await conversation()
        case (.post, "conversation/messages"):
            return try await sendMessage(body: endpoint.body)

        case (.get, "events"):
            return try fixture("events")
        case (.get, "events/souvenirs"):
            return try fixture("souvenirs")

        case (.get, "profile"):
            return try fixture("profile")
        case (.get, "profile/advisor"):
            return try fixture("advisor")

        default:
            throw APIError.unhandledEndpoint("\(endpoint.method.rawValue) \(endpoint.path)")
        }
    }

    // MARK: - Stateful endpoints

    private func catalogCurated() async throws -> Data {
        let favorites = await store.favoriteIDs()
        let dtos = MockResponses.curatedProducts(favoriteIDs: favorites)
        return try JSONEncoder.api.encode(dtos)
    }

    private func catalogWishlist() async throws -> Data {
        let favorites = await store.favoriteIDs()
        let dtos = MockResponses.curatedProducts(favoriteIDs: favorites).filter { $0.isFavorite == true }
        return try JSONEncoder.api.encode(dtos)
    }

    private func product(path: String) async throws -> Data {
        let id = String(path.dropFirst("catalog/products/".count))
        let favorite = await store.isFavorite(id)
        guard let dto = MockResponses.product(id: id, isFavorite: favorite) else {
            throw APIError.status(404)
        }
        return try JSONEncoder.api.encode(dto)
    }

    private func toggleFavorite(productPath: String) async throws -> Data {
        // catalog/products/<id>/favorite
        let trimmed = productPath
            .replacingOccurrences(of: "catalog/products/", with: "")
            .replacingOccurrences(of: "/favorite", with: "")
        let nowFavorite = await store.toggleFavorite(trimmed)
        guard let dto = MockResponses.product(id: trimmed, isFavorite: nowFavorite) else {
            throw APIError.status(404)
        }
        return try JSONEncoder.api.encode(dto)
    }

    /// `null` once cancelled; the slot booked this session if any; else the seed.
    private func nextAppointment() async throws -> Data {
        if await store.isAppointmentCancelled() {
            return Data("null".utf8)
        }
        if let dto = await store.currentBooking() {
            return try JSONEncoder.api.encode(dto)
        }
        return try fixture("nextAppointment")
    }

    private func reserve(body: Data?) async throws -> Data {
        var slotID = ""
        if let body, let payload = try? JSONDecoder.api.decode([String: String].self, from: body),
           let id = payload["slotId"] {
            slotID = id
        }
        // Build the appointment from the chosen slot, persist it so the home
        // surfaces it, and echo it back for the confirmation screen.
        let dto = MockResponses.appointment(forSlotID: slotID)
        await store.setBookedAppointment(dto)
        return try JSONEncoder.api.encode(dto)
    }

    private func conversation() async throws -> Data {
        let extra = await store.extraMessages()
        let dto = MockResponses.conversation(extraMessages: extra)
        return try JSONEncoder.api.encode(dto)
    }

    private func sendMessage(body: Data?) async throws -> Data {
        guard let body,
              let payload = try? JSONDecoder.api.decode([String: String].self, from: body),
              let text = payload["text"], !text.isEmpty else {
            throw APIError.status(400)
        }
        let memberMessage = MockResponses.memberMessage(text: text)
        await store.appendMessage(memberMessage)
        // Simulate the advisor's auto-reply landing in the thread.
        await store.appendMessage(MockResponses.advisorAutoReply())
        let extra = await store.extraMessages()
        let dto = MockResponses.conversation(extraMessages: extra)
        return try JSONEncoder.api.encode(dto)
    }

    // MARK: - Fixture loading

    /// Load a bundled JSON fixture by name, falling back to an in-code response
    /// when the resource isn't in the bundle.
    private func fixture(_ name: String) throws -> Data {
        if let url = bundle.url(forResource: name, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            return data
        }
        return try MockResponses.fallback(for: name)
    }
}
