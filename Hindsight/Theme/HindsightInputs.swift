//
//  HindsightInputs.swift
//  Hindsight
//
//  Dark-themed text input controls used throughout the forms.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - HTextField

/// A single-line text field styled for the dark theme.
struct HTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String? = nil
    /// Optional stable identifier for UI tests, since these fields have no
    /// visible label to query by.
    var accessibilityIdentifier: String? = nil

    var body: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            }
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        .font(HindsightTheme.Typography.body)
                }
                TextField("", text: $text)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .font(HindsightTheme.Typography.body)
                    .tint(HindsightTheme.Colors.accent)
                    .accessibilityIdentifier(accessibilityIdentifier ?? "")
            }
        }
        .padding(.horizontal, HindsightTheme.Spacing.md)
        .padding(.vertical, 13)
        .background(HindsightTheme.Colors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .strokeBorder(HindsightTheme.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - HTextEditor

/// A multi-line text editor with a placeholder, styled for the dark theme.
struct HTextEditor: View {
    @Binding var text: String
    var placeholder: String
    var minHeight: CGFloat = 110
    /// Optional stable identifier for UI tests, since these fields have no
    /// visible label to query by.
    var accessibilityIdentifier: String? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    .font(HindsightTheme.Typography.body)
                    .padding(.horizontal, HindsightTheme.Spacing.md + 4)
                    .padding(.vertical, 16)
            }
            TextEditor(text: $text)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .font(HindsightTheme.Typography.body)
                .tint(HindsightTheme.Colors.accent)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, HindsightTheme.Spacing.sm + 4)
                .padding(.vertical, 8)
                .frame(minHeight: minHeight)
                .accessibilityIdentifier(accessibilityIdentifier ?? "")
        }
        .background(HindsightTheme.Colors.cardElevated)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .strokeBorder(HindsightTheme.Colors.border, lineWidth: 1)
        )
    }
}

// MARK: - HStepper

/// A compact labelled 1–5 stepper used for effort / risk on option cards.
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
            HStack(spacing: 6) {
                ForEach(range, id: \.self) { i in
                    Button {
                        value = i
                        HapticsManager.shared.selectionChanged()
                    } label: {
                        Text("\(i)")
                            .font(HindsightTheme.Typography.subheadline)
                            .foregroundStyle(i <= value ? .white : HindsightTheme.Colors.textTertiary)
                            .frame(width: 34, height: 34)
                            .background(i <= value ? tint : HindsightTheme.Colors.cardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
