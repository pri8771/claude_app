//
//  HindsightInputs.swift
//  Hindsight
//
//  Quiet, high-legibility input controls. Their public APIs are retained.
//

import SwiftUI

enum HStepperSelectionSemantics {
    static func isSelected(_ item: Int, currentValue: Int) -> Bool {
        item == currentValue
    }

    static func accessibilityValue(currentValue: Int, range: ClosedRange<Int>) -> String {
        if range.lowerBound == 1 {
            return "\(currentValue) out of \(range.upperBound)"
        }
        return "\(currentValue), range \(range.lowerBound) to \(range.upperBound)"
    }

    static func adjustedValue(currentValue: Int, delta: Int, range: ClosedRange<Int>) -> Int {
        min(max(range.lowerBound, currentValue + delta), range.upperBound)
    }
}

struct HTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String? = nil
    var accessibilityIdentifier: String? = nil
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            if let icon { Image(systemName: icon).foregroundStyle(HindsightTheme.Colors.steel).frame(width: 18) }
            ZStack(alignment: .leading) {
                if text.isEmpty { Text(placeholder).foregroundStyle(HindsightTheme.Colors.textTertiary).font(HindsightTheme.Typography.body) }
                TextField("", text: $text)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .font(HindsightTheme.Typography.body)
                    .tint(HindsightTheme.Colors.accent)
                    .accessibilityIdentifier(accessibilityIdentifier ?? "")
                    .accessibilityLabel(accessibilityLabel ?? placeholder)
                    .accessibilityHint(accessibilityHint ?? "Double-tap to enter or edit text.")
                    .focused($isFocused)
                    .toolbar {
                        if isFocused {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") { isFocused = false }
                                    .accessibilityIdentifier("\(accessibilityIdentifier ?? "textField").keyboardDone")
                            }
                        }
                    }
            }
        }
        .padding(.horizontal, HindsightTheme.Spacing.md)
        .frame(minHeight: 48)
        .background(HindsightTheme.Colors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous).strokeBorder(HindsightTheme.Colors.border, lineWidth: 1))
    }
}

struct HTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var minHeight: CGFloat = 110
    var accessibilityIdentifier: String? = nil
    /// Use a contextual label when the visual placeholder alone is not enough.
    /// The placeholder remains a useful, backwards-compatible fallback.
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder).foregroundStyle(HindsightTheme.Colors.textTertiary).font(HindsightTheme.Typography.body)
                    .padding(.horizontal, HindsightTheme.Spacing.md + 4).padding(.vertical, 15)
                    .accessibilityHidden(true)
            }
            TextEditor(text: $text)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .font(HindsightTheme.Typography.body)
                .tint(HindsightTheme.Colors.accent)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, HindsightTheme.Spacing.sm + 4).padding(.vertical, 7)
                .frame(minHeight: max(48, minHeight))
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
                .accessibilityLabel(accessibilityLabel ?? placeholder)
                .accessibilityHint(accessibilityHint ?? "Double-tap to enter or edit text.")
                .focused($isFocused)
                .toolbar {
                    if isFocused {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") { isFocused = false }
                                .accessibilityIdentifier("\(accessibilityIdentifier ?? "textEditor").keyboardDone")
                        }
                    }
                }
        }
        .background(HindsightTheme.Colors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous).strokeBorder(HindsightTheme.Colors.border, lineWidth: 1))
    }
}

struct HStepper: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...5
    var tint: Color = HindsightTheme.Colors.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
                .accessibilityHidden(true)
            HStack(spacing: 6) {
                ForEach(range, id: \.self) { item in
                    Button { value = item; HapticsManager.shared.selectionChanged() } label: {
                        Text("\(item)").font(HindsightTheme.Typography.subheadline).monospacedDigit()
                            .foregroundStyle(item <= value ? HindsightTheme.Colors.surface : HindsightTheme.Colors.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(item <= value ? tint : HindsightTheme.Colors.cardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous).strokeBorder(item <= value ? tint : HindsightTheme.Colors.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(label) \(item)")
                    .accessibilityValue(HStepperSelectionSemantics.isSelected(item, currentValue: value) ? "Selected" : "Not selected")
                    .accessibilityAddTraits(HStepperSelectionSemantics.isSelected(item, currentValue: value) ? .isSelected : [])
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
        .accessibilityValue(HStepperSelectionSemantics.accessibilityValue(currentValue: value, range: range))
        .accessibilityHint("Swipe up or down to adjust, or choose a value.")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                setValue(HStepperSelectionSemantics.adjustedValue(currentValue: value, delta: 1, range: range))
            case .decrement:
                setValue(HStepperSelectionSemantics.adjustedValue(currentValue: value, delta: -1, range: range))
            @unknown default:
                break
            }
        }
    }

    private func setValue(_ candidate: Int) {
        guard candidate != value else { return }
        value = candidate
        HapticsManager.shared.selectionChanged()
    }
}
