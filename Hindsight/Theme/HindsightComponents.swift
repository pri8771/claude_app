//
//  HindsightComponents.swift
//  Hindsight
//
//  Reusable Editorial Observatory + Quiet Instrument primitives. Existing
//  public component names remain stable while their visual language changes.
//

import SwiftUI

struct HCard<Content: View>: View {
    var padding: CGFloat = HindsightTheme.Spacing.md
    var background: Color = HindsightTheme.Colors.card
    @ViewBuilder var content: () -> Content

    var body: some View {
        content().padding(padding).frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous).strokeBorder(HindsightTheme.Colors.border, lineWidth: 1))
            .hindsightShadow()
    }
}

struct HButton: View {
    enum Style { case primary, secondary, destructive }
    let title: String
    var icon: String? = nil
    var style: Style = .primary
    var fullWidth: Bool = true
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HindsightTheme.Spacing.sm) {
                if let icon { Image(systemName: icon).font(.system(size: 14, weight: .semibold)) }
                Text(title)
            }
            .font(HindsightTheme.Typography.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 48)
            .padding(.horizontal, HindsightTheme.Spacing.md)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous).strokeBorder(border, lineWidth: 1))
        }
        .buttonStyle(.plain).opacity(isEnabled ? 1 : 0.46).disabled(!isEnabled)
        .accessibilityIdentifier(title)
    }

    private var foreground: Color { style == .primary ? HindsightTheme.Colors.surface : (style == .destructive ? HindsightTheme.Colors.accent : HindsightTheme.Colors.textPrimary) }
    private var background: Color {
        switch style {
        case .primary: return HindsightTheme.Colors.textPrimary
        case .secondary: return HindsightTheme.Colors.cardElevated
        case .destructive: return HindsightTheme.Colors.accent.opacity(0.08)
        }
    }
    private var border: Color { style == .primary ? HindsightTheme.Colors.textPrimary : (style == .destructive ? HindsightTheme.Colors.accent.opacity(0.55) : HindsightTheme.Colors.borderStrong) }
}

struct HBadge: View {
    let text: String
    var icon: String? = nil
    var color: Color = HindsightTheme.Colors.accent
    var filled: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon { Image(systemName: icon).font(.system(size: 10, weight: .semibold)) }
            Text(text).font(HindsightTheme.Typography.caption2)
        }
        .foregroundStyle(filled ? HindsightTheme.Colors.surface : color)
        .padding(.horizontal, 8).frame(minHeight: 28)
        .background(filled ? color : color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous).strokeBorder(color.opacity(filled ? 0 : 0.55), lineWidth: 1))
    }
}

/// Integer percentage slider with a large gesture target and explicit VoiceOver
/// adjustment. Position, label, and color are redundant channels of meaning.
struct HSlider: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...100
    var tint: Color = HindsightTheme.Colors.accent
    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 20

    var body: some View {
        VStack(spacing: HindsightTheme.Spacing.sm) {
            HStack {
                Text("\(value)%").font(HindsightTheme.Typography.title2).monospacedDigit().foregroundStyle(HindsightTheme.Colors.textPrimary)
                Spacer()
                Text(confidenceLabel).font(HindsightTheme.Typography.caption).foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            GeometryReader { geometry in
                let span = max(1, range.upperBound - range.lowerBound)
                let fraction = CGFloat(value - range.lowerBound) / CGFloat(span)
                let usableWidth = max(1, geometry.size.width - thumbSize)
                let position = usableWidth * fraction
                ZStack(alignment: .leading) {
                    Capsule().fill(HindsightTheme.Colors.border).frame(height: trackHeight)
                    Capsule().fill(tint).frame(width: position + thumbSize / 2, height: trackHeight)
                    Circle().fill(HindsightTheme.Colors.surface).frame(width: thumbSize, height: thumbSize)
                        .overlay(Circle().strokeBorder(tint, lineWidth: 2)).offset(x: position)
                }
                .frame(height: 44).contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0).onChanged { gesture in
                    let clamped = min(max(0, gesture.location.x - thumbSize / 2), usableWidth)
                    let next = range.lowerBound + Int((clamped / usableWidth * CGFloat(span)).rounded())
                    setValue(next)
                })
            }
            .frame(height: 44)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Confidence")
            .accessibilityValue("\(value) percent, \(confidenceLabel)")
            .accessibilityHint("Swipe up or down to adjust confidence by one percent")
            .accessibilityAdjustableAction { direction in
                switch direction { case .increment: setValue(value + 1); case .decrement: setValue(value - 1); @unknown default: break }
            }
        }
    }
    private func setValue(_ candidate: Int) {
        let clamped = min(max(range.lowerBound, candidate), range.upperBound)
        guard clamped != value else { return }
        value = clamped
        HapticsManager.shared.selectionChanged()
    }
    private var confidenceLabel: String {
        switch value { case 0...20: return "Very unlikely"; case 21...40: return "Unlikely"; case 41...60: return "Even odds"; case 61...80: return "Likely"; default: return "Very likely" }
    }
}

struct HStarRating: View {
    @Binding var rating: Int
    var max: Int = 5
    var size: CGFloat = 28
    var tint: Color = HindsightTheme.Colors.amber
    var isEditable: Bool = true
    var accessibilityLabel: String = "Rating"

    init(rating: Binding<Int>, max: Int = 5, size: CGFloat = 28, tint: Color = HindsightTheme.Colors.amber, isEditable: Bool = true, accessibilityLabel: String = "Rating") {
        _rating = rating
        self.max = max
        self.size = size
        self.tint = tint
        self.isEditable = isEditable
        self.accessibilityLabel = accessibilityLabel
    }

    init(value: Int, max: Int = 5, size: CGFloat = 16, tint: Color = HindsightTheme.Colors.amber, accessibilityLabel: String = "Rating") {
        _rating = .constant(value)
        self.max = max
        self.size = size
        self.tint = tint
        isEditable = false
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        Group {
            if isEditable {
                ratingRow
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            setRating(rating + 1)
                        case .decrement:
                            setRating(rating - 1)
                        @unknown default:
                            break
                        }
                    }
            } else {
                ratingRow
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(rating) out of \(max)")
        .accessibilityHint(isEditable ? "Swipe up or down to adjust the rating." : "")
    }

    private var ratingRow: some View {
        HStack(spacing: size * 0.16) {
            ForEach(1...max, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star").font(.system(size: size)).foregroundStyle(index <= rating ? tint : HindsightTheme.Colors.textTertiary)
                    .frame(minWidth: isEditable ? 44 : 0, minHeight: isEditable ? 44 : 0)
                    .contentShape(Rectangle()).onTapGesture { guard isEditable else { return }; rating = index; HapticsManager.shared.selectionChanged() }
            }
        }
    }

    private func setRating(_ candidate: Int) {
        let clamped = Swift.min(Swift.max(1, candidate), max)
        guard clamped != rating else { return }
        rating = clamped
        HapticsManager.shared.selectionChanged()
    }
}

struct HProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 10
    var size: CGFloat = 90
    var tint: Color = HindsightTheme.Colors.accent
    var label: String? = nil
    var caption: String? = nil
    var accessibilityLabel: String? = nil
    var accessibilityValue: String? = nil
    var body: some View {
        let bounded = Swift.max(0, Swift.min(1, progress))
        ZStack {
            Circle().stroke(HindsightTheme.Colors.border, lineWidth: lineWidth)
            Circle().trim(from: 0, to: Swift.max(0.001, bounded)).stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)).rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                if let label { Text(label).font(.system(size: size * 0.25, weight: .semibold, design: .default)).monospacedDigit().foregroundStyle(HindsightTheme.Colors.textPrimary) }
                if let caption { Text(caption).font(.system(size: size * 0.13, weight: .medium, design: .default)).foregroundStyle(HindsightTheme.Colors.textSecondary) }
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? caption ?? "Progress")
        .accessibilityValue(accessibilityValue ?? label ?? "\(Int((bounded * 100).rounded())) percent")
    }
}

struct HSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var tint: Color = HindsightTheme.Colors.textPrimary
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: HindsightTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) { if let systemImage { Image(systemName: systemImage).font(.system(size: 13, weight: .semibold)).foregroundStyle(tint) }; Text(title).font(HindsightTheme.Typography.title2).foregroundStyle(HindsightTheme.Colors.textPrimary) }
                if let subtitle { Text(subtitle).font(HindsightTheme.Typography.footnote).foregroundStyle(HindsightTheme.Colors.textSecondary) }
            }
            Spacer()
            if let actionTitle, let action { Button(action: action) { Text(actionTitle).font(HindsightTheme.Typography.subheadline).foregroundStyle(HindsightTheme.Colors.accent).frame(minHeight: 44) } }
        }
        .overlay(alignment: .bottom) { Rectangle().fill(HindsightTheme.Colors.border).frame(height: 1).offset(y: 6) }
        .padding(.bottom, 7)
    }
}

struct HEmptyState: View {
    let icon: String; let title: String; let message: String; var actionTitle: String? = nil; var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: HindsightTheme.Spacing.md) {
            Image(systemName: icon).font(.system(size: 30, weight: .regular)).foregroundStyle(HindsightTheme.Colors.steel).frame(width: 56, height: 56).overlay(Circle().strokeBorder(HindsightTheme.Colors.border, lineWidth: 1))
            VStack(spacing: HindsightTheme.Spacing.xs) { Text(title).font(HindsightTheme.Typography.title2).foregroundStyle(HindsightTheme.Colors.textPrimary); Text(message).font(HindsightTheme.Typography.callout).foregroundStyle(HindsightTheme.Colors.textSecondary).multilineTextAlignment(.center) }.padding(.horizontal, HindsightTheme.Spacing.lg)
            if let actionTitle, let action { HButton(title: actionTitle, icon: "plus", style: .primary, fullWidth: false, action: action).padding(.top, HindsightTheme.Spacing.xs) }
        }.frame(maxWidth: .infinity).padding(.vertical, HindsightTheme.Spacing.xl)
    }
}

struct HStatTile: View {
    let value: String; let label: String; var tint: Color = HindsightTheme.Colors.accent; var icon: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let icon { Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundStyle(tint) }
            Text(value).font(HindsightTheme.Typography.stat).foregroundStyle(HindsightTheme.Colors.textPrimary).minimumScaleFactor(0.6).lineLimit(1)
            Text(label).font(HindsightTheme.Typography.caption).foregroundStyle(HindsightTheme.Colors.textSecondary).lineLimit(2).fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(HindsightTheme.Spacing.md).background(HindsightTheme.Colors.card).clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)).overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous).strokeBorder(HindsightTheme.Colors.border, lineWidth: 1))
    }
}

struct HMeter: View {
    let label: String; let value: Int; var tint: Color = HindsightTheme.Colors.textSecondary
    var body: some View {
        VStack(alignment: .leading, spacing: 4) { Text(label.uppercased()).font(HindsightTheme.Typography.caption2).foregroundStyle(HindsightTheme.Colors.textTertiary); HStack(spacing: 3) { ForEach(1...5, id: \.self) { index in Rectangle().fill(index <= value ? tint : HindsightTheme.Colors.border).frame(height: 5) } } }
        .accessibilityElement(children: .ignore).accessibilityLabel(label).accessibilityValue("\(value) out of 5")
    }
}
