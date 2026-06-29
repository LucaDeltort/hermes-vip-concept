//
//  Theme.swift
//  hermes-vip-concept
//
//

import SwiftUI

/// The app's design-system namespace. Use `Theme.Font`, `Theme.Spacing`, etc.
/// Colors live as colorsets in the asset catalog — reference `Color(.accent)`.
enum Theme {

    // MARK: - Spacing (8pt-based scale)

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        /// Standard horizontal screen inset.
        static let screen: CGFloat = 24
    }

    // MARK: - Radii

    enum Radius {
        static let chip: CGFloat = 12
        static let card: CGFloat = 12
        static let input: CGFloat = 12
        static let button: CGFloat = 28      // pill
        static let tabBar: CGFloat = 30
        static let bubble: CGFloat = 18
    }

    // MARK: - Metrics

    enum Metrics {
        static let buttonHeight: CGFloat = 56
        static let hairlineWidth: CGFloat = 0.5
        static let borderWidth: CGFloat = 1
        /// Uniform height for the Profile preference rows (toggle + disclosure).
        static let preferenceRowHeight: CGFloat = 56
    }

    // MARK: - Typography
    //
    // New York (serif) for display/headings; SF Mono for eyebrows/labels.
    // New York is exposed by SwiftUI via `.system(..., design: .serif)`.

    enum Font {
        // Display & headings (serif).
        static func display(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .serif)
        }

        static func displayItalic(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .serif).italic()
        }

        // Eyebrows / labels / metadata (mono, uppercased + wide tracking at call site).
        static func mono(_ size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .monospaced)
        }

        // Body copy.
        static func body(_ size: CGFloat = 16, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: .default)
        }
    }

    // MARK: - Tracking presets (letter-spacing from the mockup, .16em–.46em)

    enum Tracking {
        static func wide(_ fontSize: CGFloat) -> CGFloat { fontSize * 0.16 }
        static func wider(_ fontSize: CGFloat) -> CGFloat { fontSize * 0.30 }
        static func widest(_ fontSize: CGFloat) -> CGFloat { fontSize * 0.46 }
    }
}
