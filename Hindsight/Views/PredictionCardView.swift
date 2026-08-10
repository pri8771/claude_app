//
//  PredictionCardView.swift
//  Hindsight
//
//  A read-only card showing a single prediction: its statement, the
//  stated probability, the due date, and how it eventually resolved.
//

import SwiftUI

struct PredictionCardView: View {
    let prediction: Prediction

    var body: some View {
        HCard(background: HindsightTheme.Colors.cardElevated) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
                    // Confidence ring
                    HProgressRing(
                        progress: Double(prediction.probabilityPercent) / 100,
                        lineWidth: 6,
                        size: 50,
                        tint: ringTint,
                        label: "\(prediction.probabilityPercent)",
                        accessibilityLabel: "Stated confidence",
                        accessibilityValue: "\(prediction.probabilityPercent) percent"
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(prediction.title)
                            .font(HindsightTheme.Typography.callout)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 6) {
                            HBadge(text: prediction.status.eventOutcomeLabel, icon: prediction.status.icon,
                                   color: prediction.status.color,
                                   filled: prediction.status != .pending)
                            Text(dueText)
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        }
                    }
                    Spacer(minLength: 0)
                }

                if let result = prediction.actualResult, !result.isEmpty {
                    Divider().overlay(HindsightTheme.Colors.border)
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        Text(result)
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                }
            }
        }
    }

    private var ringTint: Color {
        switch prediction.status {
        case .pending:   return HindsightTheme.Colors.amber
        case .correct:   return HindsightTheme.Colors.success
        case .incorrect: return HindsightTheme.Colors.accent
        case .partial:   return HindsightTheme.Colors.amber
        }
    }

    private var dueText: String {
        if prediction.status == .pending {
            return "Resolves \(prediction.dueDate.formatted(.dateTime.month(.abbreviated).day()))"
        }
        return "Resolved"
    }
}

#Preview {
    VStack(spacing: 16) {
        PredictionCardView(prediction: Prediction(title: "I'll still feel good about this in 30 days",
                                                  probabilityPercent: 72, dueDate: .now, status: .correct,
                                                  actualResult: "Felt great, no regrets."))
        PredictionCardView(prediction: Prediction(title: "The commute will get to me",
                                                  probabilityPercent: 40, dueDate: .now))
    }
    .padding()
    .hindsightBackground()
}
