//
//  ReviewDateStep.swift
//  Hindsight
//
//  Step 4 of the wizard: pick the review date, see the calculated clarity
//  score, and review a summary of everything entered before saving.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private struct ReviewPreset: Identifiable {
    var id: String { label }
    let label: String
    let days: Int
}

struct ReviewDateStep: View {
    @Bindable var draft: DecisionDraft

    private let presets: [ReviewPreset] = [
        ReviewPreset(label: "1 week", days: 7),
        ReviewPreset(label: "1 month", days: 30),
        ReviewPreset(label: "3 months", days: 90),
        ReviewPreset(label: "6 months", days: 180),
        ReviewPreset(label: "1 year", days: 365)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                // Clarity score
                HCard {
                    HStack(spacing: HindsightTheme.Spacing.lg) {
                        HProgressRing(
                            progress: Double(draft.clarityScore) / 100,
                            lineWidth: 9, size: 88,
                            tint: HindsightTheme.Colors.amber,
                            label: "\(draft.clarityScore)", caption: "/ 100"
                        )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Clarity Score")
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            Text(ClarityScore.label(for: draft.clarityScore))
                                .font(HindsightTheme.Typography.subheadline)
                                .foregroundStyle(HindsightTheme.Colors.amber)
                            Text("How thoroughly you thought this through.")
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                    }
                }

                // Review date
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("When should we check back?")
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("We'll remind you to review how this turned out.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HindsightTheme.Spacing.sm) {
                            ForEach(presets) { preset in
                                let date = Calendar.current.date(byAdding: .day, value: preset.days, to: Date()) ?? Date()
                                Button {
                                    draft.reviewDate = date
                                    #if canImport(UIKit)
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    #endif
                                } label: {
                                    Text(preset.label)
                                        .font(HindsightTheme.Typography.subheadline)
                                        .foregroundStyle(isSelected(preset.days) ? .white : HindsightTheme.Colors.textPrimary)
                                        .padding(.horizontal, HindsightTheme.Spacing.md)
                                        .padding(.vertical, 9)
                                        .background(isSelected(preset.days) ? HindsightTheme.Colors.accent : HindsightTheme.Colors.card)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().strokeBorder(HindsightTheme.Colors.border,
                                                                        lineWidth: isSelected(preset.days) ? 0 : 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HCard {
                        DatePicker("Review date", selection: $draft.reviewDate, in: Date()...,
                                   displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(HindsightTheme.Colors.accent)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    }
                }

                // Summary
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    HSectionHeader(title: "Summary", systemImage: "list.bullet.clipboard")
                    HCard {
                        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                            summaryRow(icon: "text.quote", label: "Decision",
                                       value: draft.title.isEmpty ? "—" : draft.title)
                            Divider().overlay(HindsightTheme.Colors.border)
                            summaryRow(icon: draft.category.icon, label: "Category",
                                       value: draft.category.rawValue, tint: draft.category.color)
                            summaryRow(icon: draft.stakes.icon, label: "Stakes",
                                       value: draft.stakes.rawValue, tint: draft.stakes.color)
                            summaryRow(icon: "square.stack.3d.up", label: "Options",
                                       value: "\(draft.validOptions.count) considered")
                            summaryRow(icon: "scope", label: "Predictions",
                                       value: "\(draft.validPredictions.count) made")
                            summaryRow(icon: "calendar", label: "Review",
                                       value: draft.reviewDate.formatted(.dateTime.month(.wide).day().year()))
                        }
                    }
                }

                Color.clear.frame(height: 12)
            }
            .padding(HindsightTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private func isSelected(_ days: Int) -> Bool {
        let target = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return Calendar.current.isDate(draft.reviewDate, inSameDayAs: target)
    }

    private func summaryRow(icon: String, label: String, value: String,
                            tint: Color = HindsightTheme.Colors.textSecondary) -> some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 22)
            Text(label)
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
            Spacer()
            Text(value)
                .font(HindsightTheme.Typography.subheadline)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .lineLimit(1)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ReviewDateStep(draft: DecisionDraft())
        .hindsightBackground()
        .preferredColorScheme(.dark)
}
