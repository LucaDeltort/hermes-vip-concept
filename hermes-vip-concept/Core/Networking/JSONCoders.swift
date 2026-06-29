//
//  JSONCoders.swift
//  hermes-vip-concept
//
//

import Foundation

extension JSONDecoder {
    /// Decoder matching the API wire format.
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension JSONEncoder {
    /// Encoder matching the API wire format.
    static let api: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
