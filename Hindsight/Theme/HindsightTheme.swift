//
//  HindsightTheme.swift
//  Hindsight
//
//  Central design system: colour palette, typography, spacing, corner
//  radii and shadows. Everything visual references this namespace so the
//  dark, premium look stays consistent across the app.
//

import SwiftUI

// MARK: - Color from hex

extension Color {
    /// Creates a colour from a hex string ("RGB", "RRGGBB" or "AARRGGBB").
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8: // AARRGGBB (32-bit)
            (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme namespace

enum HindsightTheme {

    // MARK: Colours
    enum Colors {
        /// App background — dark navy.
        static let background    = Color(hex: "1A1A2E")
        /// Slightly raised surface (navigation, sheets).
        static let surface       = Color(hex: "16213E")
        /// Card background.
        static let card          = Color(hex: "232544")
        /// Elevated card / pressed state.
        static let cardElevated  = Color(hex: "2A2C52")

        /// Primary accent — red.
        static let accent        = Color(hex: "E94560")
        /// Secondary accent — amber / gold.
        static let amber         = Color(hex: "F5A623")
        /// Positive accent — green.
        static let success       = Color(hex: "4CAF50")

        static let textPrimary   = Color.white
        static let textSecondary = Color(hex: "A0A0B8")
        static let textTertiary  = Color(hex: "6B6B85")

        static let border        = Color.white.opacity(0.08)
        static let borderStrong  = Color.white.opacity(0.16)

        /// A soft, premium top-to-bottom background gradient.
        static var backgroundGradient: LinearGradient {
            LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16162B"), Color(hex: "120F24")],
                startPoint: .top,
                endPoint: .bottom
            )
        }

        /// Subtle accent glow gradient used on highlight cards.
        static var accentGradient: LinearGradient {
            LinearGradient(
                colors: [accent, Color(hex: "C2334B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: Corner radius
    enum Radius {
        static let sm: CGFloat   = 8
        static let md: CGFloat   = 14
        static let lg: CGFloat   = 20
        static let xl: CGFloat   = 28
        static let pill: CGFloat = 999
    }

    // MARK: Typography (SF Pro, rounded for a premium feel)
    enum Typography {
        static let largeTitle = Font.system(size: 32, weight: .bold,      design: .rounded)
        static let title      = Font.system(size: 24, weight: .bold,      design: .rounded)
        static let title2     = Font.system(size: 20, weight: .semibold,  design: .rounded)
        static let headline   = Font.system(size: 17, weight: .semibold,  design: .rounded)
        static let body       = Font.system(size: 16, weight: .regular,   design: .default)
        static let callout    = Font.system(size: 15, weight: .regular,   design: .default)
        static let subheadline = Font.system(size: 14, weight: .medium,   design: .rounded)
        static let footnote   = Font.system(size: 13, weight: .regular,   design: .default)
        static let caption    = Font.system(size: 12, weight: .medium,    design: .rounded)
        static let caption2   = Font.system(size: 11, weight: .semibold,  design: .rounded)
        /// Big numeric display used for stats.
        static let stat       = Font.system(size: 28, weight: .heavy,     design: .rounded)
    }

    // MARK: Shadows
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    enum Shadows {
        static let card    = ShadowStyle(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
        static let raised  = ShadowStyle(color: .black.opacity(0.45), radius: 20, x: 0, y: 10)
        static let glow    = ShadowStyle(color: Colors.accent.opacity(0.45), radius: 18, x: 0, y: 8)
    }
}

// MARK: - Convenience view modifiers

extension View {
    /// Applies the standard dark background gradient, ignoring safe areas.
    func hindsightBackground() -> some View {
        background(HindsightTheme.Colors.backgroundGradient.ignoresSafeArea())
    }

    /// Applies a theme shadow style.
    func hindsightShadow(_ style: HindsightTheme.ShadowStyle = HindsightTheme.Shadows.card) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
