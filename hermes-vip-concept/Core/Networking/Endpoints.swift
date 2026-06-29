//
//  Endpoints.swift
//  hermes-vip-concept
//
//

import Foundation

extension Endpoint {
    enum Invitation {
        static func validate(code: String) -> Endpoint {
            Endpoint(
                path: "invitation/validate",
                method: .post,
                body: try? JSONEncoder.api.encode(["code": code])
            )
        }
    }

    enum Catalog {
        static func curated() -> Endpoint {
            Endpoint(path: "catalog/curated")
        }
        static func editorial() -> Endpoint {
            Endpoint(path: "catalog/editorial")
        }
        static func product(id: String) -> Endpoint {
            Endpoint(path: "catalog/products/\(id)")
        }
        static func wishlist() -> Endpoint {
            Endpoint(path: "catalog/wishlist")
        }
        static func owned() -> Endpoint {
            Endpoint(path: "catalog/owned")
        }
        static func toggleFavorite(id: String) -> Endpoint {
            Endpoint(path: "catalog/products/\(id)/favorite", method: .put)
        }
    }

    enum Booking {
        static func nextAppointment() -> Endpoint {
            Endpoint(path: "booking/next")
        }
        static func slots(month: Date) -> Endpoint {
            Endpoint(
                path: "booking/slots",
                queryItems: [
                    URLQueryItem(name: "month", value: ISO8601DateFormatter().string(from: month))
                ]
            )
        }
        static func book(slotID: String) -> Endpoint {
            Endpoint(
                path: "booking/reserve",
                method: .post,
                body: try? JSONEncoder.api.encode(["slotId": slotID])
            )
        }
        static func cancel(appointmentID: String) -> Endpoint {
            Endpoint(path: "booking/appointments/\(appointmentID)", method: .delete)
        }
    }

    enum Conversation {
        static func thread() -> Endpoint {
            Endpoint(path: "conversation")
        }
        static func send(text: String) -> Endpoint {
            Endpoint(
                path: "conversation/messages",
                method: .post,
                body: try? JSONEncoder.api.encode(["text": text])
            )
        }
    }

    enum Events {
        static func list() -> Endpoint {
            Endpoint(path: "events")
        }
        static func souvenirs() -> Endpoint {
            Endpoint(path: "events/souvenirs")
        }
    }

    enum Profile {
        static func profile() -> Endpoint {
            Endpoint(path: "profile")
        }
        static func advisor() -> Endpoint {
            Endpoint(path: "profile/advisor")
        }
    }
}
