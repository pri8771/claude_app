//
//  OnboardingView.swift
//  Hindsight
//
//  A concise, reflection-first introduction to the private calibration loop.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: AppRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sampleLoadError: String?

    private enum Finish {
        case firstForecast
        case exampleData
        case empty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xl) {
                header
                explanation
                illustrativeInsight
                actions
                privacyNote
            }
            .frame(maxWidth: 620, alignment: .leading)
            .padding(.horizontal, HindsightTheme.Spacing.lg)
            .padding(.vertical, HindsightTheme.Spacing.xxl)
        }
        .background(HindsightTheme.Colors.background.ignoresSafeArea())
        .alert("Couldn't load example records", isPresented: Binding(
            get: { sampleLoadError != nil },
            set: { if !$0 { sampleLoadError = nil } }
        )) {
            Button("Try Again") { finish(.exampleData) }
            Button("Keep choosing", role: .cancel) { sampleLoadError = nil }
        } message: {
            Text(sampleLoadError ?? "Nothing was added. Your existing data is unchanged.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            Text("HINDSIGHT")
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(HindsightTheme.Colors.steel)
                .tracking(1.2)

            Text("A record of your judgment before the outcome is known.")
                .font(HindsightTheme.Typography.editorialDisplay)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Capture a forecast, state how confident you are, and return when the evidence is available. Over time, Hindsight helps you see whether your confidence is calibrated to what actually happens.")
                .font(HindsightTheme.Typography.body)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 0) {
            conceptRow(
                number: "01",
                title: "Forecast",
                detail: "Write a specific belief while the result is still uncertain."
            )
            Divider().overlay(HindsightTheme.Colors.border)
            conceptRow(
                number: "02",
                title: "Confidence",
                detail: "Choose 0–100% intentionally. It records how likely you thought the outcome was."
            )
            Divider().overlay(HindsightTheme.Colors.border)
            conceptRow(
                number: "03",
                title: "Outcome",
                detail: "Later, mark whether it happened, did not happen, or could not be judged."
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .stroke(HindsightTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("How Hindsight works")
    }

    private func conceptRow(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            Text(number)
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(HindsightTheme.Colors.steel)
                .frame(width: 28, alignment: .leading)

            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                Text(title)
                    .font(HindsightTheme.Typography.headline)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(detail)
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(HindsightTheme.Spacing.md)
    }

    private var illustrativeInsight: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            Label("ILLUSTRATIVE PERSONAL INSIGHT", systemImage: "chart.xyaxis.line")
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(HindsightTheme.Colors.steel)

            Text("In 8 resolved forecasts stated at 80% or higher, the outcome happened 6 times.")
                .font(HindsightTheme.Typography.authoredStatement)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Example only — 6 of 8 eligible resolved forecasts. Your insights appear only from your own resolved forecasts; samples are excluded.")
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.card)
        .overlay(
            Rectangle()
                .fill(HindsightTheme.Colors.steel)
                .frame(width: 3),
            alignment: .leading
        )
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .stroke(HindsightTheme.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            Text("Choose a starting point")
                .font(HindsightTheme.Typography.headline)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)

            onboardingAction(
                title: "Record first forecast",
                detail: "Open a private forecast and begin with what you believe now.",
                style: .primary,
                action: { finish(.firstForecast) }
            )
            onboardingAction(
                title: "Explore example data",
                detail: "Load clearly marked sample records. They never affect your personal insights or export.",
                style: .secondary,
                action: { finish(.exampleData) }
            )
            onboardingAction(
                title: "Start empty",
                detail: "Go to Today without adding anything.",
                style: .secondary,
                action: { finish(.empty) }
            )
        }
    }

    private func onboardingAction(
        title: String,
        detail: String,
        style: OnboardingActionStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: HindsightTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                    Text(title)
                        .font(HindsightTheme.Typography.headline)
                    Text(detail)
                        .font(HindsightTheme.Typography.footnote)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: HindsightTheme.Spacing.sm)
                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(style.foreground)
            .padding(HindsightTheme.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(style.background)
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .stroke(style.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint(detail)
    }

    private var privacyNote: some View {
        Text("Private on this device. No account or public profile is required.")
            .font(HindsightTheme.Typography.footnote)
            .foregroundStyle(HindsightTheme.Colors.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func finish(_ kind: Finish) {
        switch kind {
        case .firstForecast:
            router.presentQuickCapture = true
        case .exampleData:
            let inserted = SampleData.insertIfMissing(into: context)
            guard inserted || SampleData.containsDemoData(in: context) else {
                sampleLoadError = "The example records could not be saved. Nothing was added; you can retry."
                return
            }
        case .empty:
            break
        }
        HapticsManager.shared.onboardingCompleted()
        if reduceMotion {
            hasCompletedOnboarding = true
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

private enum OnboardingActionStyle {
    case primary
    case secondary

    var foreground: Color {
        switch self {
        case .primary: HindsightTheme.Colors.surface
        case .secondary: HindsightTheme.Colors.textPrimary
        }
    }

    var background: Color {
        switch self {
        case .primary: HindsightTheme.Colors.textPrimary
        case .secondary: HindsightTheme.Colors.card
        }
    }

    var border: Color {
        switch self {
        case .primary: HindsightTheme.Colors.textPrimary
        case .secondary: HindsightTheme.Colors.borderStrong
        }
    }
}

// These compatibility components remain available to the legacy onboarding
// subviews while the root uses the quieter, single-screen presentation above.
// Their colors resolve through the app-wide adaptive theme rather than a
// separate forced-dark palette.
enum OnboardingTheme {
    enum Colors {
        static let background = HindsightTheme.Colors.background
        static let accent = HindsightTheme.Colors.accent
        static let amber = HindsightTheme.Colors.amber
        static let card = HindsightTheme.Colors.card
        static let elevated = HindsightTheme.Colors.cardElevated
        static let textPrimary = HindsightTheme.Colors.textPrimary
        static let textSecondary = HindsightTheme.Colors.textSecondary
        static let border = HindsightTheme.Colors.border
    }
}

struct OnboardingBackground: View {
    let page: Int

    var body: some View {
        HindsightTheme.Colors.background
    }
}

struct OnboardingButton: View {
    enum Kind { case primary, secondary, tertiary }

    let title: String
    var icon: String? = nil
    var kind: Kind = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HindsightTheme.Spacing.sm) {
                Text(title)
                if let icon {
                    Image(systemName: icon)
                }
            }
            .font(HindsightTheme.Typography.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(foreground)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .stroke(border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        kind == .primary ? HindsightTheme.Colors.surface : HindsightTheme.Colors.textPrimary
    }

    private var background: Color {
        switch kind {
        case .primary: HindsightTheme.Colors.textPrimary
        case .secondary: HindsightTheme.Colors.card
        case .tertiary: .clear
        }
    }

    private var border: Color {
        kind == .tertiary ? .clear : HindsightTheme.Colors.border
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppRouter())
        .modelContainer(SampleData.previewContainer)
}
