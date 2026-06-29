//
//  MockResponses.swift
//  hermes-vip-concept
//
//

import Foundation

enum MockResponses {

    // MARK: - Invitation

    /// Accept any non-empty code; codes containing "REFUS" are rejected (so the
    /// error path is demoable). Echoes the submitted code back.
    static func invitationValidate(body: Data?) throws -> Data {
        var code = ""
        if let body,
           let payload = try? JSONDecoder.api.decode([String: String].self, from: body) {
            code = payload["code"] ?? ""
        }
        let valid = !code.isEmpty && !code.uppercased().contains("REFUS")
        let dto = InvitationCodeDTO(
            id: "inv-001",
            code: code,
            valid: valid,
            memberName: valid ? "Camille" : nil
        )
        return try JSONEncoder.api.encode(dto)
    }

    // MARK: - Catalog

    static func curatedProducts(favoriteIDs: Set<String>) -> [ProductDTO] {
        Product.samples.map { productDTO(from: $0, isFavorite: favoriteIDs.contains($0.id)) }
    }

    static func product(id: String, isFavorite: Bool) -> ProductDTO? {
        guard let product = Product.samples.first(where: { $0.id == id }) else { return nil }
        return productDTO(from: product, isFavorite: isFavorite)
    }

    /// Build a wire DTO from a domain product. This entity→wire mapping lives in
    /// the mock "back office" (not the DTO) so `ProductDTO` stays a pure
    /// wire→entity type. Defaults to the entity's own `isFavorite`.
    private static func productDTO(from product: Product, isFavorite: Bool? = nil) -> ProductDTO {
        ProductDTO(
            id: product.id,
            name: product.name,
            category: product.category,
            material: product.material,
            color: product.color,
            description: product.description,
            advisorNote: product.advisorNote,
            badge: product.badge?.rawValue,
            imageAssets: product.imageAssets,
            isFavorite: isFavorite ?? product.isFavorite
        )
    }

    static func ownedPieces() -> [OwnedPieceDTO] {
        OwnedPiece.samples.map {
            OwnedPieceDTO(
                id: $0.id, name: $0.name, category: $0.category,
                material: $0.material, color: $0.color, year: $0.year,
                imageAssets: $0.imageAssets
            )
        }
    }

    static func editorial() -> [EditorialMomentDTO] {
        EditorialMoment.samples.map {
            EditorialMomentDTO(
                id: $0.id, eyebrow: $0.eyebrow, title: $0.title,
                quote: $0.quote, imageAsset: $0.imageAsset
            )
        }
    }

    // MARK: - Booking

    static func bookingSlots() throws -> Data {
        let dtos = BookingSlot.samples().map {
            BookingSlotDTO(id: $0.id, date: $0.date, label: $0.label, available: $0.isAvailable)
        }
        return try JSONEncoder.api.encode(dtos)
    }

    /// Build the appointment for a reserved slot, using the chosen slot's date
    /// (falls back to the sample date if the slot id is unknown).
    static func appointment(forSlotID slotID: String) -> AppointmentDTO {
        let sample = Appointment.sample
        let slot = BookingSlot.samples().first { $0.id == slotID }
        return AppointmentDTO(
            id: slotID.isEmpty ? sample.id : "apt-\(slotID)",
            title: sample.title,
            boutique: sample.boutique,
            date: slot?.date ?? sample.date,
            advisorName: sample.advisorName
        )
    }

    static func nextAppointment() -> AppointmentDTO {
        let a = Appointment.sample
        return AppointmentDTO(
            id: a.id, title: a.title, boutique: a.boutique,
            date: a.date, advisorName: a.advisorName
        )
    }

    // MARK: - Conversation

    static func conversation(extraMessages: [MessageDTO]) -> ConversationDTO {
        let base = Conversation.sample
        let baseDTOs = base.messages.map {
            MessageDTO(
                id: $0.id, sender: $0.sender.rawValue,
                text: $0.text, timestamp: $0.timestamp,
                product: $0.product.map { productDTO(from: $0) }
            )
        }
        let advisor = base.advisor
        return ConversationDTO(
            id: base.id,
            advisor: AdvisorDTO(
                id: advisor.id, name: advisor.name, title: advisor.title,
                boutique: advisor.boutique, introduction: advisor.introduction,
                portraitAsset: advisor.portraitAsset
            ),
            messages: baseDTOs + extraMessages
        )
    }

    static func memberMessage(text: String) -> MessageDTO {
        MessageDTO(id: UUID().uuidString, sender: "member", text: text, timestamp: Date())
    }

    static func advisorAutoReply() -> MessageDTO {
        MessageDTO(
            id: UUID().uuidString,
            sender: "advisor",
            text: "Bien noté, je m'en occupe immédiatement et reviens vers vous.",
            timestamp: Date().addingTimeInterval(1)
        )
    }

    // MARK: - Events

    static func events() -> [EventDTO] {
        Event.samples.map {
            EventDTO(
                id: $0.id, title: $0.title, location: $0.location, date: $0.date,
                summary: $0.summary, eyebrow: $0.eyebrow, imageAsset: $0.imageAsset
            )
        }
    }

    static func souvenirs() -> [SouvenirDTO] {
        Souvenir.samples.map {
            SouvenirDTO(
                id: $0.id, title: $0.title, caption: $0.caption, photoAssets: $0.photoAssets
            )
        }
    }

    // MARK: - Profile

    static func profile() -> MemberProfileDTO {
        let p = MemberProfile.sample
        return MemberProfileDTO(
            id: p.id, name: p.name, tier: p.tier, memberSince: p.memberSince,
            email: p.email,
            advisor: p.advisor.map { advisor in
                AdvisorDTO(
                    id: advisor.id, name: advisor.name, title: advisor.title,
                    boutique: advisor.boutique, introduction: advisor.introduction,
                    portraitAsset: advisor.portraitAsset
                )
            },
            avatarAsset: p.avatarAsset
        )
    }

    static func advisor() -> AdvisorDTO {
        let a = Advisor.sample
        return AdvisorDTO(
            id: a.id, name: a.name, title: a.title, boutique: a.boutique,
            introduction: a.introduction, portraitAsset: a.portraitAsset
        )
    }

    // MARK: - Fixture fallback

    /// In-code JSON for read endpoints when the bundled .json isn't found.
    static func fallback(for name: String) throws -> Data {
        switch name {
        case "editorial":        return try JSONEncoder.api.encode(editorial())
        case "nextAppointment":  return try JSONEncoder.api.encode(nextAppointment())
        case "events":           return try JSONEncoder.api.encode(events())
        case "souvenirs":        return try JSONEncoder.api.encode(souvenirs())
        case "profile":          return try JSONEncoder.api.encode(profile())
        case "advisor":          return try JSONEncoder.api.encode(advisor())
        default:
            throw APIError.unhandledEndpoint("fixture:\(name)")
        }
    }
}
