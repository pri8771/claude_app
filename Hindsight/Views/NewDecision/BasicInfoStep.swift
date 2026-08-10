//
//  BasicInfoStep.swift
//  Hindsight
//
//  Step 1 of the wizard: title, category, stakes, reversibility and notes.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BasicInfoStep: View {
    @Bindable var draft: DecisionDraft

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                // Title
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("What are you deciding?")
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    TextField("", text: $draft.title, axis: .vertical)
                        .placeholder(when: draft.title.isEmpty) {
                            Text("e.g. Should I take the new job?")
                                .foregroundStyle(HindsightTheme.Colors.textTertiary)
                                .font(HindsightTheme.Typography.title2)
                        }
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .tint(HindsightTheme.Colors.accent)
                        .lineLimit(1...4)
                        .padding(HindsightTheme.Spacing.md)
                        .background(HindsightTheme.Colors.cardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
                        .accessibilityIdentifier("newDecision.title")
                }

                // Category grid
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("Category")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    LazyVGrid(columns: columns, spacing: HindsightTheme.Spacing.sm) {
                        ForEach(DecisionCategory.allCases) { category in
                            CategoryButton(category: category, isSelected: draft.category == category) {
                                draft.category = category
                            }
                        }
                    }
                }

                // Stakes
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("How high are the stakes?")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    ForEach(StakesLevel.allCases) { level in
                        StakesRow(level: level, isSelected: draft.stakes == level) {
                            draft.stakes = level
                        }
                    }
                }

                // Reversible toggle
                HCard {
                    Toggle(isOn: $draft.isReversible) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Is it reversible?")
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            Text(draft.isReversible ? "You could walk this back later" : "This one's hard to undo")
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                    }
                    .tint(HindsightTheme.Colors.success)
                }

                // Notes
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("Context / notes")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    HTextEditor(text: $draft.notes, placeholder: "Why does this decision matter right now? (optional)", minHeight: 90)
                }

                Color.clear.frame(height: 12)
            }
            .padding(HindsightTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("newDecision.basics.scroll")
    }
}

// MARK: - Category button

private struct CategoryButton: View {
    let category: DecisionCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            HapticsManager.shared.selectionChanged()
        }) {
            HStack(spacing: HindsightTheme.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : category.color)
                Text(category.rawValue)
                    .font(HindsightTheme.Typography.subheadline)
                    .foregroundStyle(isSelected ? .white : HindsightTheme.Colors.textPrimary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, HindsightTheme.Spacing.md)
            .padding(.vertical, 13)
            .background(isSelected ? category.color : HindsightTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                    .strokeBorder(isSelected ? .clear : HindsightTheme.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stakes row

private struct StakesRow: View {
    let level: StakesLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            HapticsManager.shared.selectionChanged()
        }) {
            HStack(spacing: HindsightTheme.Spacing.md) {
                Image(systemName: level.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(level.color)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 1) {
                    Text(level.rawValue)
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text(level.detail)
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? level.color : HindsightTheme.Colors.textTertiary)
            }
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                    .strokeBorder(isSelected ? level.color.opacity(0.6) : HindsightTheme.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Placeholder helper

extension View {
    /// Overlays placeholder content while a condition (usually "is empty") holds.
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    BasicInfoStep(draft: DecisionDraft())
        .hindsightBackground()
}
