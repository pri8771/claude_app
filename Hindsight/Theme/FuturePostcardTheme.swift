//
//  FuturePostcardTheme.swift
//  Hindsight
//
//  Compatibility facade for the in-flight Future Postcards slice. The public
//  names are retained; the visual language is now Editorial Observatory,
//  without stamps, rotation, postcard paper, or decorative shadows.
//

import SwiftUI

enum FuturePostcardTheme {
    enum Colors {
        static let paper = HindsightTheme.Colors.background
        static let paperRaised = HindsightTheme.Colors.card
        static let ink = HindsightTheme.Colors.textPrimary
        static let inkMuted = HindsightTheme.Colors.textSecondary
        static let rust = HindsightTheme.Colors.accent
        static let amber = HindsightTheme.Colors.amber
        static let sage = HindsightTheme.Colors.success
        static let steel = HindsightTheme.Colors.steel
        static let line = HindsightTheme.Colors.borderStrong
        static let softLine = HindsightTheme.Colors.border
    }
    enum Radius { static let card: CGFloat = HindsightTheme.Radius.lg; static let control: CGFloat = HindsightTheme.Radius.md; static let pill: CGFloat = HindsightTheme.Radius.pill }
    enum Typography {
        static let display = HindsightTheme.Typography.editorialDisplay
        static let title = HindsightTheme.Typography.title
        static let headline = HindsightTheme.Typography.headline
        static let body = HindsightTheme.Typography.body
        static let label = HindsightTheme.Typography.metadata
        static let metadata = HindsightTheme.Typography.metadata
    }
}

/// Compatibility label; intentionally rendered as a neutral instrument tag,
/// rather than a stamp. Call sites can migrate the wording independently.
struct FuturePostcardStamp: View {
    let text: String
    var color: Color = FuturePostcardTheme.Colors.amber
    var body: some View {
        Text(text.uppercased()).font(FuturePostcardTheme.Typography.label).tracking(0.55)
            .foregroundStyle(FuturePostcardTheme.Colors.ink).padding(.horizontal, 8).frame(minHeight: 28)
            .background(color.opacity(0.13)).clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous).stroke(color.opacity(0.75), lineWidth: 1))
            .accessibilityLabel(text)
    }
}

struct FuturePostcardSurface<Content: View>: View {
    @ViewBuilder let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View { HCard(padding: 18, background: FuturePostcardTheme.Colors.paperRaised) { content } }
}

struct FuturePostcardDecisionCard: View {
    let decision: Decision
    var emphasiseDue = false
    var body: some View {
        FuturePostcardSurface {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    FuturePostcardStamp(text: stateLabel, color: stateColor)
                    Spacer(minLength: 12)
                    Text("RECORDED \(decision.createdAt.formatted(.dateTime.day().month(.abbreviated).year()))").font(FuturePostcardTheme.Typography.metadata).foregroundStyle(FuturePostcardTheme.Colors.inkMuted)
                }
                Text(decision.title).font(HindsightTheme.Typography.authoredStatement).foregroundStyle(FuturePostcardTheme.Colors.ink).multilineTextAlignment(.leading).lineLimit(3)
                if !decision.notes.isEmpty { Text(decision.notes).font(FuturePostcardTheme.Typography.body).foregroundStyle(FuturePostcardTheme.Colors.inkMuted).lineLimit(2) }
                Divider().overlay(FuturePostcardTheme.Colors.softLine)
                HStack(spacing: 12) {
                    Label("\(decision.averageConfidence)%", systemImage: "gauge.with.dots.needle.67percent").monospacedDigit()
                    Spacer(minLength: 4)
                    Label(returnLabel, systemImage: "calendar")
                }.font(FuturePostcardTheme.Typography.metadata).foregroundStyle(FuturePostcardTheme.Colors.inkMuted)
                if SampleData.isDemoDecision(decision) { Text("SAMPLE · EXCLUDED FROM PERSONAL INSIGHTS").font(FuturePostcardTheme.Typography.metadata).foregroundStyle(FuturePostcardTheme.Colors.rust) }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: FuturePostcardTheme.Radius.card, style: .continuous).stroke(emphasiseDue ? FuturePostcardTheme.Colors.rust : .clear, lineWidth: emphasiseDue ? 1.5 : 0))
        .accessibilityElement(children: .combine).accessibilityLabel(accessibilitySummary)
    }
    private var stateLabel: String { decision.status == .reviewed ? "Resolved" : (decision.needsReview ? "Review due" : "Recorded") }
    private var stateColor: Color { decision.status == .reviewed ? FuturePostcardTheme.Colors.sage : (decision.needsReview ? FuturePostcardTheme.Colors.rust : FuturePostcardTheme.Colors.steel) }
    private var returnLabel: String { if decision.status == .reviewed, let date = decision.outcomeReview?.reviewedAt { return "Resolved \(date.formatted(.dateTime.month(.abbreviated).day()))" }; return decision.needsReview ? "Review due" : "Review \(decision.dueDate.formatted(.dateTime.month(.abbreviated).day()))" }
    private var accessibilitySummary: String { var parts = [stateLabel, decision.title, "\(decision.averageConfidence) percent confident", returnLabel]; if SampleData.isDemoDecision(decision) { parts.append("Sample record") }; return parts.joined(separator: ", ") }
}

extension View {
    func futurePostcardScreen() -> some View {
        background(HindsightTheme.Colors.background.ignoresSafeArea()).foregroundStyle(HindsightTheme.Colors.textPrimary)
            .toolbarBackground(HindsightTheme.Colors.surface, for: .navigationBar).toolbarBackground(.visible, for: .navigationBar)
    }
}
