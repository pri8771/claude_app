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

                // Clears the sticky navigationButtons bar in NewDecisionWizard
                // (~82pt: 50pt button + 16pt vertical padding × 2). TabView's
                // .page style doesn't reliably propagate the parent's
                // safeAreaInset into each page's ScrollView content, so this
                // must be sized explicitly rather than relying on that.
                Color.clear.frame(height: 100)
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

                HTextEditor(text: $prediction.statement, placeholder: placeholder, minHeight: 60,
                            accessibilityIdentifier: "newDecision.prediction.statement.\(index)")

                VStack(alignment: .leading, spacing: 6) {
                    Text("HOW CONFIDENT ARE YOU?")
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    PredictionConfidenceSlider(
                        value: $prediction.probability,
                        accessibilityIdentifier: "newDecision.prediction.confidence.\(index)"
                    )
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

/// A 0–100 slider that is visually centered but semantically unselected until
/// the person interacts with it. The neutral position is not a hidden 50%.
private struct PredictionConfidenceSlider: View {
    @Binding var value: Int?
    let accessibilityIdentifier: String

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(value ?? 50) },
            set: { candidate in
                let next = min(100, max(0, Int(candidate.rounded())))
                guard next != value else { return }
                value = next
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(value.map { "\($0)%" } ?? "Not selected")
                    .font(HindsightTheme.Typography.title2)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Spacer()
                Text(confidenceLabel)
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }

            Slider(
                value: sliderValue,
                in: 0...100,
                step: 1,
                onEditingChanged: { isEditing in
                    // The neutral thumb rests at 50 without selecting it.
                    // Touching that exact position is still an intentional
                    // choice, even if SwiftUI never calls the value setter.
                    if isEditing, value == nil {
                        value = 50
                    } else if !isEditing, value != nil {
                        HapticsManager.shared.selectionChanged()
                    }
                }
            )
                .tint(value == nil ? HindsightTheme.Colors.textTertiary : HindsightTheme.Colors.accent)
                .accessibilityIdentifier(accessibilityIdentifier)
                .accessibilityLabel("Confidence")
                .accessibilityValue(accessibilityValue)
                .accessibilityHint(value == nil
                    ? "No value selected. Swipe up or down to choose a confidence from zero to one hundred percent."
                    : "Swipe up or down to adjust confidence by one percent.")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment:
                        setAccessibleValue(value.map { $0 + 1 } ?? 50)
                    case .decrement:
                        setAccessibleValue(value.map { $0 - 1 } ?? 50)
                    @unknown default:
                        break
                    }
                }

            HStack {
                Text("0%")
                Spacer()
                Text("100%")
            }
            .font(HindsightTheme.Typography.caption2)
            .foregroundStyle(HindsightTheme.Colors.textTertiary)

            if value == nil {
                Text("Move the slider to record your confidence.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
    }

    private var accessibilityValue: String {
        guard let value else { return "Not selected" }
        return "\(value) percent, \(confidenceLabel)"
    }

    private var confidenceLabel: String {
        guard let value else { return "Choose a value" }
        switch value {
        case 0...20: return "Very unlikely"
        case 21...40: return "Unlikely"
        case 41...60: return "Even odds"
        case 61...80: return "Likely"
        default: return "Very likely"
        }
    }

    private func setAccessibleValue(_ candidate: Int) {
        let next = min(100, max(0, candidate))
        guard next != value else { return }
        value = next
        HapticsManager.shared.selectionChanged()
    }
}

#Preview {
    PredictionsStep(draft: DecisionDraft())
        .hindsightBackground()
}
