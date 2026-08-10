//
//  HindsightTheme.swift
//  Hindsight
//
//  Editorial Observatory + Quiet Instrument foundations. Tokens are semantic
//  so the same information stays legible in light, dark, and high-contrast
//  system appearances.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Color from hex

extension Color {
    /// Creates a colour from a hex string ("RGB", "RRGGBB" or "AARRGGBB").
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3: (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
        case 6: (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8: (a, r, g, b) = (value >> 24, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255,
                  blue: Double(b) / 255, opacity: Double(a) / 255)
    }

    /// A deliberately small adaptive bridge while the app has no color asset
    /// catalog. High contrast preserves the same semantic meaning with greater
    /// separation; it never changes a state into a different color.
    static func hindsightAdaptive(light: String, dark: String,
                                  lightHighContrast: String? = nil,
                                  darkHighContrast: String? = nil) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            let highContrast = traits.accessibilityContrast == .high
            let hex: String
            switch (isDark, highContrast) {
            case (false, true): hex = lightHighContrast ?? light
            case (true, true): hex = darkHighContrast ?? dark
            case (false, false): hex = light
            case (true, false): hex = dark
            }
            return UIColor(Color(hex: hex))
        })
        #else
        return Color(hex: light)
        #endif
    }
}

enum HindsightTheme {
    enum Colors {
        static let background = Color.hindsightAdaptive(light: "F3F0E8", dark: "171716", lightHighContrast: "FFFFFF", darkHighContrast: "000000")
        static let surface = Color.hindsightAdaptive(light: "FAF8F2", dark: "1E1E1C", lightHighContrast: "FFFFFF", darkHighContrast: "121211")
        static let card = Color.hindsightAdaptive(light: "FCFAF5", dark: "242421", lightHighContrast: "FFFFFF", darkHighContrast: "1B1B19")
        static let cardElevated = Color.hindsightAdaptive(light: "ECE8DF", dark: "30302C", lightHighContrast: "F4F4F4", darkHighContrast: "373734")

        /// Semantic accents: oxblood for attention/destructive states, brass
        /// for pending review, steel for neutral mechanics, verdigris for a
        /// confirmed positive result.
        static let accent = Color.hindsightAdaptive(light: "8D2E29", dark: "D47B70", lightHighContrast: "741C18", darkHighContrast: "FF9B8F")
        static let amber = Color.hindsightAdaptive(light: "8A661B", dark: "D5AF57", lightHighContrast: "654600", darkHighContrast: "FFE08A")
        static let success = Color.hindsightAdaptive(light: "35645C", dark: "78B6AA", lightHighContrast: "174D45", darkHighContrast: "A4E5D7")
        static let steel = Color.hindsightAdaptive(light: "52636B", dark: "AAB7B9", lightHighContrast: "33464D", darkHighContrast: "D3E0E2")

        /// Category and stakes roles remain distinct without bypassing the
        /// adaptive, high-contrast color system. Labels and icons always carry
        /// the meaning; these colors are supporting cues only.
        static let categoryCareer = Color.hindsightAdaptive(light: "3E5F7A", dark: "9AC4E8", lightHighContrast: "1F496B", darkHighContrast: "C7E6FF")
        static let categoryHealth = Color.hindsightAdaptive(light: "7A4D72", dark: "D5A6CB", lightHighContrast: "5A2D52", darkHighContrast: "FFD0F3")
        static let categoryPersonal = Color.hindsightAdaptive(light: "5D5788", dark: "B7B1EA", lightHighContrast: "3C376B", darkHighContrast: "D9D5FF")
        static let categoryEducation = Color.hindsightAdaptive(light: "276C68", dark: "82C8C1", lightHighContrast: "07514D", darkHighContrast: "B7EEE7")
        static let stakesHigh = Color.hindsightAdaptive(light: "8A4A22", dark: "E1A16D", lightHighContrast: "66300E", darkHighContrast: "FFC28E")

        static let textPrimary = Color.hindsightAdaptive(light: "22211E", dark: "F1EEE7", lightHighContrast: "000000", darkHighContrast: "FFFFFF")
        static let textSecondary = Color.hindsightAdaptive(light: "635F57", dark: "C6C1B7", lightHighContrast: "3C3933", darkHighContrast: "E7E1D6")
        static let textTertiary = Color.hindsightAdaptive(light: "827C72", dark: "9C978E", lightHighContrast: "555049", darkHighContrast: "C8C2B8")
        static let border = Color.hindsightAdaptive(light: "D6D0C5", dark: "494842", lightHighContrast: "706A60", darkHighContrast: "9E9A90")
        static let borderStrong = Color.hindsightAdaptive(light: "AAA398", dark: "747169", lightHighContrast: "4D4841", darkHighContrast: "D4CFC4")

        // Compatibility names intentionally resolve to flat fills: the new
        // system has no decorative gradients.
        static var backgroundGradient: LinearGradient { LinearGradient(colors: [background, background], startPoint: .top, endPoint: .bottom) }
        static var accentGradient: LinearGradient { LinearGradient(colors: [accent, accent], startPoint: .top, endPoint: .bottom) }
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 6
        static let lg: CGFloat = 8
        static let xl: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Layout {
        /// Keeps reading and input lines comfortably scannable on iPad while
        /// remaining a no-op on compact iPhones.
        static let readableMaxWidth: CGFloat = 760
    }

    enum Typography {
        // SF Pro is the mechanical UI face. Serif is reserved for authored
        // statements and editorial headings, never controls or metadata.
        static let largeTitle = Font.system(.largeTitle, design: .default).weight(.semibold)
        static let title = Font.system(.title, design: .default).weight(.semibold)
        static let title2 = Font.system(.title2, design: .default).weight(.semibold)
        static let headline = Font.system(.headline, design: .default)
        static let body = Font.system(.body, design: .default)
        static let callout = Font.system(.callout, design: .default)
        static let subheadline = Font.system(.subheadline, design: .default).weight(.medium)
        static let footnote = Font.system(.footnote, design: .default)
        static let caption = Font.system(.caption, design: .default).weight(.medium)
        static let caption2 = Font.system(.caption2, design: .default).weight(.semibold)
        static let stat = Font.system(.title, design: .default).weight(.semibold).monospacedDigit()
        static let authoredStatement = Font.system(.title2, design: .serif)
        static let editorialDisplay = Font.system(.largeTitle, design: .serif).weight(.semibold)
        static let metadata = Font.system(.caption, design: .monospaced).weight(.medium).monospacedDigit()
    }

    struct ShadowStyle { let color: Color; let radius: CGFloat; let x: CGFloat; let y: CGFloat }
    enum Shadows {
        static let card = ShadowStyle(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        static let raised = ShadowStyle(color: .black.opacity(0.07), radius: 2, x: 0, y: 1)
        static let glow = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
    }
}

extension View {
    func hindsightBackground() -> some View { background(HindsightTheme.Colors.background.ignoresSafeArea()) }
    func hindsightReadableWidth(alignment: Alignment = .leading) -> some View {
        frame(maxWidth: HindsightTheme.Layout.readableMaxWidth, alignment: alignment)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    func hindsightShadow(_ style: HindsightTheme.ShadowStyle = HindsightTheme.Shadows.card) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
