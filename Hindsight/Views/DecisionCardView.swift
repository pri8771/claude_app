//
//  DecisionCardView.swift
//  Hindsight
//
//  Compact card summarising a single decision, used in lists on the
//  Today and Decisions screens.
//

import SwiftUI
import SwiftData

struct DecisionCardView: View {
    let decision: Decision
    /// Highlights the card in red when it needs attention.
    var emphasiseReview: Bool = false

    var body: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                // Title + category icon
                HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(decision.category.color.opacity(0.18))
                            .frame(width: 38, height: 38)
                        Image(systemName: decision.category.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(decision.category.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(decision.title)
                            .font(HindsightTheme.Typography.headline)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text(decision.category.rawValue)
                            .font(HindsightTheme.Typography.caption)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                }

                // Badges
                HStack(spacing: 6) {
                    HBadge(text: decision.stakesLevel.rawValue, icon: decision.stakesLevel.icon,
                           color: decision.stakesLevel.color)
                    HBadge(text: decision.status.rawValue, icon: decision.status.icon,
                           color: decision.status.color)
                    if !decision.predictions.isEmpty {
                        HBadge(text: "\(decision.predictions.count) prediction\(decision.predictions.count == 1 ? "" : "s")",
                               icon: "scope", color: HindsightTheme.Colors.textSecondary)
                    }
                }

                // Footer: due / reviewed line
                footer
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .strokeBorder(emphasiseReview ? HindsightTheme.Colors.accent.opacity(0.6) : .clear, lineWidth: 1.5)
        )
    }

    @ViewBuilder private var footer: some View {
        switch decision.status {
        case .reviewed:
            if let review = decision.outcomeReview {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(HindsightTheme.Colors.success)
                    Text(review.hasOutcomeQuality ? "Reviewed · outcome" : "Reviewed")
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    if review.hasOutcomeQuality {
                        HStarRating(value: review.outcomeQuality, size: 12)
                    }
                }
                .font(HindsightTheme.Typography.caption)
            }
        case .awaitingReview where decision.needsReview:
            label("Review overdue", icon: "exclamationmark.circle.fill", color: HindsightTheme.Colors.accent)
        case .awaitingReview:
            label(reviewDateText, icon: "calendar", color: HindsightTheme.Colors.amber)
        case .active:
            label("Deciding · review \(reviewDateShort)", icon: "circle.dashed", color: HindsightTheme.Colors.textSecondary)
        }
    }

    private func label(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color)
            Text(text).foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
        .font(HindsightTheme.Typography.caption)
    }

    private var reviewDateText: String {
        let days = decision.daysUntilReview
        if days == 0 { return "Review due today" }
        if days == 1 { return "Review tomorrow" }
        return "Review in \(days) days"
    }

    private var reviewDateShort: String {
        decision.dueDate.formatted(.dateTime.month(.abbreviated).day())
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(try! SampleData.previewContainer.mainContext.fetch(FetchDescriptor<Decision>())) { d in
                DecisionCardView(decision: d, emphasiseReview: d.needsReview)
            }
        }
        .padding()
    }
    .hindsightBackground()
    .modelContainer(SampleData.previewContainer)
}
