//
//  OptionsStep.swift
//  Hindsight
//
//  Step 2 of the wizard: add 2–5 options, each with trade-offs, effort,
//  risk and a gut-feeling rating.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct OptionsStep: View {
    @Bindable var draft: DecisionDraft

    private let maxOptions = 5

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("What are your options?")
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Add at least two choices you're weighing.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }

                ForEach(Array(draft.options.enumerated()), id: \.element.id) { index, option in
                    OptionEditorCard(
                        option: option,
                        index: index,
                        canDelete: draft.options.count > 2,
                        onDelete: { remove(option) }
                    )
                }

                if draft.options.count < maxOptions {
                    Button {
                        withAnimation { draft.options.append(OptionDraft()) }
                        HapticsManager.shared.itemAdded()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add another option")
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

    private func remove(_ option: OptionDraft) {
        withAnimation { draft.options.removeAll { $0.id == option.id } }
        HapticsManager.shared.itemRemoved()
    }
}

// MARK: - Option editor card

private struct OptionEditorCard: View {
    @Bindable var option: OptionDraft
    let index: Int
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                HStack {
                    Text("Option \(index + 1)")
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

                HTextField(text: $option.title, placeholder: "Option title", icon: "circle")

                HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
                    labelledField(label: "UPSIDE", tint: HindsightTheme.Colors.success) {
                        HTextField(text: $option.upside, placeholder: "What's good")
                    }
                }
                labelledField(label: "DOWNSIDE", tint: HindsightTheme.Colors.accent) {
                    HTextField(text: $option.downside, placeholder: "What's bad")
                }

                HStack(alignment: .top, spacing: HindsightTheme.Spacing.lg) {
                    HStepper(label: "Effort", value: $option.effort, tint: HindsightTheme.Colors.amber)
                    HStepper(label: "Risk", value: $option.risk, tint: HindsightTheme.Colors.accent)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("GUT FEELING")
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    HStarRating(rating: $option.gutFeeling, size: 26)
                }
            }
        }
    }

    private func labelledField<Content: View>(label: String, tint: Color,
                                              @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(tint)
            content()
        }
    }
}

#Preview {
    OptionsStep(draft: DecisionDraft())
        .hindsightBackground()
        .preferredColorScheme(.dark)
}
