//
//  PredictionsStep.swift
//  Hindsight
//
//  Step 3 of the wizard: add 1–5 falsifiable predictions about the
//  future, each with a probability and a date it resolves.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PredictionsStep: View {
    @Bindable var draft: DecisionDraft

    private let maxPredictions = 5
    private let placeholders = [
        "I'll still feel good about this in 30 days",
        "This will pay off financially within a year",
        "I won't regret saying no",
        "My stress level will drop"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What do you predict?")
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Make falsifiable bets about the future. Future you will grade them.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }

                ForEach(Array(draft.predictions.enumerated()), id: \.element.id) { index, prediction in
                    PredictionEditorCard(
                        prediction: prediction,
                        index: index,
                        placeholder: placeholders[index % placeholders.count],
                        canDelete: draft.predictions.count > 1,
                        onDelete: { remove(prediction) }
                    )
                }

                if draft.predictions.count < maxPredictions {
                    Button {
                        withAnimation { draft.predictions.append(PredictionDraft()) }
                        HapticsManager.shared.itemAdded()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add another prediction")
                        }
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HindsightTheme.Colors.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                                .strokeBorder(HindsightTheme.Colors.accent.opacity(0.3),
                                              style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                    }
                    .buttonStyle(.plain)
                }

                Color.clear.frame(height: 12)
            }
            .padding(HindsightTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private func remove(_ prediction: PredictionDraft) {
        withAnimation { draft.predictions.removeAll { $0.id == prediction.id } }
        HapticsManager.shared.itemRemoved()
    }
}

// MARK: - Prediction editor card

private struct PredictionEditorCard: View {
    @Bindable var prediction: PredictionDraft
    let index: Int
    let placeholder: String
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                HStack {
                    Text("Prediction \(index + 1)")
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    Spacer()
                    if canDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 13))
                                .foregroundStyle(HindsightTheme.Colors.accent)
                        }
                    }
                }

                HTextEditor(text: $prediction.statement, placeholder: placeholder, minHeight: 60)

                VStack(alignment: .leading, spacing: 6) {
                    Text("HOW CONFIDENT ARE YOU?")
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    HSlider(value: $prediction.probability)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("RESOLVES ON")
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    DatePicker("", selection: $prediction.dueDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(HindsightTheme.Colors.accent)
                }
            }
        }
    }
}

#Preview {
    PredictionsStep(draft: DecisionDraft())
        .hindsightBackground()
        .preferredColorScheme(.dark)
}
