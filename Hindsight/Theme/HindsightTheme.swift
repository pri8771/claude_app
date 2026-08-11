//
//  HindsightTheme.swift
//  Hindsight
//
//  Signal Garden foundations. The palette is joyful and luminous without
//  turning the product into a game: indigo is the primary action, while coral,
//  aqua, lime, and warm yellow are supporting signals whose meaning is always
//  repeated in text or iconography.
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
        static let background = Color.hindsightAdaptive(
            light: "F8F8FF", dark: "0C1024",
            lightHighContrast: "FFFFFF", darkHighContrast: "050713"
        )
        static let backgroundTop = Color.hindsightAdaptive(
            light: "F5F2FF", dark: "121632",
            lightHighContrast: "FFFFFF", darkHighContrast: "090C1D"
        )
        static let backgroundBottom = Color.hindsightAdaptive(
            light: "F2FBFC", dark: "0C1829",
            lightHighContrast: "F7FFFF", darkHighContrast: "07131F"
        )
        static let surface = Color.hindsightAdaptive(
            light: "FFFFFF", dark: "151A33",
            lightHighContrast: "FFFFFF", darkHighContrast: "10142A"
        )
        static let card = Color.hindsightAdaptive(
            light: "FFFFFF", dark: "1B213D",
            lightHighContrast: "FFFFFF", darkHighContrast: "171D36"
        )
        static let cardElevated = Color.hindsightAdaptive(
            light: "F0F1FF", dark: "242B4B",
            lightHighContrast: "E9EBFF", darkHighContrast: "2D355A"
        )
        static let tabBarSurface = Color.hindsightAdaptive(
            light: "FBFBFF", dark: "11162D",
            lightHighContrast: "FFFFFF", darkHighContrast: "090D20"
        )

        /// Primary and supporting Signal Garden hues. Semantic UI never relies
        /// on these colors alone; labels, symbols, and values remain present.
        static let accent = Color.hindsightAdaptive(
            light: "5146E5", dark: "8F83FF",
            lightHighContrast: "3428CC", darkHighContrast: "B8B0FF"
        )
        static let violet = Color.hindsightAdaptive(
            light: "7C3AED", dark: "B18AFF",
            lightHighContrast: "5B21B6", darkHighContrast: "D0B8FF"
        )
        static let coral = Color.hindsightAdaptive(
            light: "E84F64", dark: "FF8796",
            lightHighContrast: "B91F3B", darkHighContrast: "FFB4BE"
        )
        static let aqua = Color.hindsightAdaptive(
            light: "087F86", dark: "60DDE0",
            lightHighContrast: "005D64", darkHighContrast: "A0F6F7"
        )
        static let lime = Color.hindsightAdaptive(
            light: "588A14", dark: "A6DE5B",
            lightHighContrast: "356A00", darkHighContrast: "D1FFA0"
        )
        static let warmYellow = Color.hindsightAdaptive(
            light: "A56800", dark: "FFD166",
            lightHighContrast: "7A4800", darkHighContrast: "FFE6A3"
        )
        static let danger = coral
        static let amber = warmYellow
        static let success = Color.hindsightAdaptive(
            light: "16845C", dark: "64D6A6",
            lightHighContrast: "00633E", darkHighContrast: "A2F1CE"
        )
        static let steel = aqua
        static let onAccent = Color.hindsightAdaptive(
            light: "FFFFFF", dark: "FFFFFF",
            lightHighContrast: "FFFFFF", darkHighContrast: "070816"
        )

        /// Category and stakes roles remain distinct without bypassing the
        /// adaptive, high-contrast color system. Labels and icons always carry
        /// the meaning; these colors are supporting cues only.
        static let categoryCareer = accent
        static let categoryHealth = coral
        static let categoryPersonal = violet
        static let categoryEducation = aqua
        static let stakesHigh = warmYellow

        static let textPrimary = Color.hindsightAdaptive(
            light: "14172D", dark: "F7F7FF",
            lightHighContrast: "050611", darkHighContrast: "FFFFFF"
        )
        static let textSecondary = Color.hindsightAdaptive(
            light: "50556F", dark: "C9CDE3",
            lightHighContrast: "30344D", darkHighContrast: "F0F2FF"
        )
        static let textTertiary = Color.hindsightAdaptive(
            light: "70758E", dark: "A8ADC8",
            lightHighContrast: "4A4F68", darkHighContrast: "D7DBF1"
        )
        static let border = Color.hindsightAdaptive(
            light: "DEE0F0", dark: "353C5C",
            lightHighContrast: "747991", darkHighContrast: "8F96B8"
        )
        static let borderStrong = Color.hindsightAdaptive(
            light: "B9BDD4", dark: "596284",
            lightHighContrast: "4F546C", darkHighContrast: "C0C7E6"
        )

        static var backgroundGradient: LinearGradient {
            LinearGradient(
                colors: [backgroundTop, background, backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        static var accentGradient: LinearGradient {
            LinearGradient(colors: [accent, violet], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        static var captureGradient: AngularGradient {
            AngularGradient(colors: [violet, accent, aqua, coral, violet], center: .center)
        }
        static var signalSpectrumGradient: LinearGradient {
            LinearGradient(
                colors: [violet, accent, aqua, lime, warmYellow, coral],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        static var cardSheenGradient: LinearGradient {
            LinearGradient(
                colors: [violet.opacity(0.08), aqua.opacity(0.025), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Layout {
        /// Keeps reading and input lines comfortably scannable on iPad while
        /// remaining a no-op on compact iPhones.
        static let readableMaxWidth: CGFloat = 760
    }

    enum Typography {
        // SF Rounded gives the app warmth while retaining an adult, highly
        // legible system face. Compatibility names intentionally lose serif.
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title, design: .rounded).weight(.bold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
        static let body = Font.system(.body, design: .rounded)
        static let callout = Font.system(.callout, design: .rounded)
        static let subheadline = Font.system(.subheadline, design: .rounded).weight(.semibold)
        static let footnote = Font.system(.footnote, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded).weight(.medium)
        static let caption2 = Font.system(.caption2, design: .rounded).weight(.semibold)
        static let stat = Font.system(.title, design: .rounded).weight(.bold).monospacedDigit()
        static let authoredStatement = Font.system(.title2, design: .rounded).weight(.medium)
        static let editorialDisplay = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let metadata = Font.system(.caption, design: .rounded).weight(.semibold).monospacedDigit()
    }

    struct ShadowStyle { let color: Color; let radius: CGFloat; let x: CGFloat; let y: CGFloat }
    enum Shadows {
        static let card = ShadowStyle(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        static let raised = ShadowStyle(color: .black.opacity(0.13), radius: 18, x: 0, y: 10)
        static let glow = ShadowStyle(color: Colors.accent.opacity(0.24), radius: 18, x: 0, y: 8)
    }

    enum Motion {
        static let gentle = Animation.easeInOut(duration: 0.28)
        static let responsive = Animation.spring(response: 0.34, dampingFraction: 0.82, blendDuration: 0.12)
        static let celebratory = Animation.spring(response: 0.44, dampingFraction: 0.72, blendDuration: 0.14)
    }
}

/// A quiet wash of signal color. It carries no information, is removed in
/// high-contrast mode, and is hidden from assistive technology.
struct SignalGardenBackground: View {
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        ZStack {
            HindsightTheme.Colors.backgroundGradient
            if colorSchemeContrast != .increased {
                Circle()
                    .fill(HindsightTheme.Colors.violet.opacity(0.11))
                    .frame(width: 330, height: 330)
                    .blur(radius: 90)
                    .offset(x: -150, y: -280)
                Circle()
                    .fill(HindsightTheme.Colors.aqua.opacity(0.09))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 170, y: 250)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct HindsightMotionModifier<Value: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let value: Value

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}

extension View {
    func hindsightBackground() -> some View { background { SignalGardenBackground() } }
    func hindsightReadableWidth(alignment: Alignment = .leading) -> some View {
        frame(maxWidth: HindsightTheme.Layout.readableMaxWidth, alignment: alignment)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    func hindsightShadow(_ style: HindsightTheme.ShadowStyle = HindsightTheme.Shadows.card) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
    func hindsightMotion<Value: Equatable>(
        _ animation: Animation = HindsightTheme.Motion.responsive,
        value: Value
    ) -> some View {
        modifier(HindsightMotionModifier(animation: animation, value: value))
    }
}
