//
//  HindsightComponents.swift
//  Hindsight
//
//  The reusable building blocks of the UI: cards, buttons, badges,
//  sliders, ratings, progress rings, section headers and empty states.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - HCard

/// A dark card container with a subtle border and shadow.
struct HCard<Content: View>: View {
    var padding: CGFloat = HindsightTheme.Spacing.md
    var background: Color = HindsightTheme.Colors.card
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .strokeBorder(HindsightTheme.Colors.border, lineWidth: 1)
            )
            .hindsightShadow()
    }
}

// MARK: - HButton

struct HButton: View {
    enum Style { case primary, secondary, destructive }

    let title: String
    var icon: String? = nil
    var style: Style = .primary
    var fullWidth: Bool = true
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        }) {
            HStack(spacing: HindsightTheme.Spacing.sm) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(HindsightTheme.Typography.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.vertical, 15)
            .padding(.horizontal, HindsightTheme.Spacing.lg)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.4)
        .disabled(!isEnabled)
    }

    private var foreground: Color {
        switch style {
        case .primary:     return .white
        case .secondary:   return HindsightTheme.Colors.textPrimary
        case .destructive: return HindsightTheme.Colors.accent
        }
    }

    @ViewBuilder private var backgroundView: some View {
        switch style {
        case .primary:     HindsightTheme.Colors.accentGradient
        case .secondary:   HindsightTheme.Colors.cardElevated
        case .destructive: HindsightTheme.Colors.accent.opacity(0.12)
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:     return .clear
        case .secondary:   return HindsightTheme.Colors.borderStrong
        case .destructive: return HindsightTheme.Colors.accent.opacity(0.4)
        }
    }
}

// MARK: - HBadge

/// A colourful pill badge for statuses and categories.
struct HBadge: View {
    let text: String
    var icon: String? = nil
    var color: Color = HindsightTheme.Colors.accent
    var filled: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).font(.system(size: 10, weight: .bold)) }
            Text(text)
                .font(HindsightTheme.Typography.caption2)
        }
        .foregroundStyle(filled ? .white : color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(filled ? color : color.opacity(0.16))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(filled ? .clear : color.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - HSlider

/// A custom-styled slider for integer percentages (0–100).
struct HSlider: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...100
    var tint: Color = HindsightTheme.Colors.accent

    private let trackHeight: CGFloat = 8
    private let thumbSize: CGFloat = 26

    var body: some View {
        VStack(spacing: HindsightTheme.Spacing.sm) {
            HStack {
                Text("\(value)%")
                    .font(HindsightTheme.Typography.title2)
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                Spacer()
                Text(confidenceLabel)
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }

            GeometryReader { geo in
                let span = CGFloat(range.upperBound - range.lowerBound)
                let fraction = CGFloat(value - range.lowerBound) / span
                let usable = geo.size.width - thumbSize
                let x = usable * fraction

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HindsightTheme.Colors.cardElevated)
                        .frame(height: trackHeight)

                    Capsule()
                        .fill(LinearGradient(colors: [tint.opacity(0.7), tint],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: x + thumbSize / 2, height: trackHeight)

                    Circle()
                        .fill(.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .overlay(Circle().strokeBorder(tint, lineWidth: 3))
                        .hindsightShadow(HindsightTheme.Shadows.card)
                        .offset(x: x)
                }
                .frame(height: thumbSize)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let clampedX = min(max(0, gesture.location.x - thumbSize / 2), usable)
                            let newFraction = usable == 0 ? 0 : clampedX / usable
                            let newValue = range.lowerBound + Int((newFraction * span).rounded())
                            if newValue != value {
                                value = min(max(range.lowerBound, newValue), range.upperBound)
                                #if canImport(UIKit)
                                UISelectionFeedbackGenerator().selectionChanged()
                                #endif
                            }
                        }
                )
            }
            .frame(height: thumbSize)
        }
    }

    private var confidenceLabel: String {
        switch value {
        case 0...20:   return "Very unlikely"
        case 21...40:  return "Unlikely"
        case 41...60:  return "Coin flip"
        case 61...80:  return "Likely"
        default:       return "Near certain"
        }
    }
}

// MARK: - HStarRating

/// A 1–5 interactive star rating. Pass `isEditable: false` for display only.
struct HStarRating: View {
    @Binding var rating: Int
    var max: Int = 5
    var size: CGFloat = 28
    var tint: Color = HindsightTheme.Colors.amber
    var isEditable: Bool = true

    init(rating: Binding<Int>, max: Int = 5, size: CGFloat = 28,
         tint: Color = HindsightTheme.Colors.amber, isEditable: Bool = true) {
        self._rating = rating
        self.max = max
        self.size = size
        self.tint = tint
        self.isEditable = isEditable
    }

    /// Convenience read-only initialiser.
    init(value: Int, max: Int = 5, size: CGFloat = 16, tint: Color = HindsightTheme.Colors.amber) {
        self._rating = .constant(value)
        self.max = max
        self.size = size
        self.tint = tint
        self.isEditable = false
    }

    var body: some View {
        HStack(spacing: size * 0.18) {
            ForEach(1...max, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(index <= rating ? tint : HindsightTheme.Colors.textTertiary)
                    .scaleEffect(index == rating && isEditable ? 1.15 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rating)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard isEditable else { return }
                        rating = index
                        #if canImport(UIKit)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                    }
            }
        }
    }
}

// MARK: - HProgressRing

/// A circular progress indicator with an optional label in the centre.
struct HProgressRing: View {
    /// Progress 0...1.
    let progress: Double
    var lineWidth: CGFloat = 10
    var size: CGFloat = 90
    var tint: Color = HindsightTheme.Colors.accent
    var label: String? = nil
    var caption: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(HindsightTheme.Colors.cardElevated, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: Swift.max(0.001, Swift.min(1, progress)))
                .stroke(
                    AngularGradient(colors: [tint.opacity(0.6), tint], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)

            VStack(spacing: 0) {
                if let label {
                    Text(label)
                        .font(.system(size: size * 0.26, weight: .heavy, design: .rounded))
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                }
                if let caption {
                    Text(caption)
                        .font(.system(size: size * 0.13, weight: .medium, design: .rounded))
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - HSectionHeader

/// A section header with an optional trailing action.
struct HSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var tint: Color = HindsightTheme.Colors.textPrimary

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(tint)
                    }
                    Text(title)
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(HindsightTheme.Typography.subheadline)
                        .foregroundStyle(HindsightTheme.Colors.accent)
                }
            }
        }
    }
}

// MARK: - HEmptyState

/// A friendly empty state with an icon, title, message and optional action.
struct HEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: HindsightTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(HindsightTheme.Colors.accent.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(HindsightTheme.Colors.accent)
            }

            VStack(spacing: HindsightTheme.Spacing.xs) {
                Text(title)
                    .font(HindsightTheme.Typography.title2)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(message)
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, HindsightTheme.Spacing.lg)

            if let actionTitle, let action {
                HButton(title: actionTitle, icon: "plus", style: .primary, fullWidth: false, action: action)
                    .padding(.top, HindsightTheme.Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HindsightTheme.Spacing.xl)
    }
}

// MARK: - Supporting small components

/// A labelled stat used in the home-screen stats strip.
struct HStatTile: View {
    let value: String
    let label: String
    var tint: Color = HindsightTheme.Colors.accent
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)
            }
            Text(value)
                .font(HindsightTheme.Typography.stat)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .strokeBorder(HindsightTheme.Colors.border, lineWidth: 1)
        )
    }
}

/// A small labelled 1–5 meter used on option cards (effort / risk).
struct HMeter: View {
    let label: String
    let value: Int
    var tint: Color = HindsightTheme.Colors.textSecondary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= value ? tint : HindsightTheme.Colors.cardElevated)
                        .frame(height: 6)
                }
            }
        }
    }
}
