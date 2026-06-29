//
//  Color+Theme.swift
//  hermes-vip-concept
//
//

import SwiftUI

extension Color {
    /// Hex initializer, e.g. `Color(hex: "F37021")`. Supports RGB & RGBA.
    init(hex: String, alpha: Double = 1) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b, a: Double
        switch cleaned.count {
        case 8: // RRGGBBAA
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        default: // RRGGBB
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = alpha
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
