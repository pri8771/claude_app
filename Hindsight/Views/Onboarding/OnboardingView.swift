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
        ZStack {
            HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()
            Circle()
                .fill(HindsightTheme.Colors.categoryPersonal.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 2)
                .offset(x: 170, y: -330)
                .accessibilityHidden(true)
            Circle()
                .fill(HindsightTheme.Colors.categoryEducation.opacity(0.10))
                .frame(width: 260, height: 260)
                .offset(x: -170, y: 420)
                .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xl) {
                    header
                    explanation
                    illustrativeInsight
                    actions
                    privacyNote
                }
                .frame(maxWidth: 660, alignment: .leading)
                .padding(.horizontal, HindsightTheme.Spacing.lg)
                .padding(.top, HindsightTheme.Spacing.xl)
                .padding(.bottom, HindsightTheme.Spacing.xxl)
            }
        }
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
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
            HStack(spacing: HindsightTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(HindsightTheme.Colors.accentGradient)
                    Image(systemName: "scope")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    Image(systemName: "sparkle")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(HindsightTheme.Colors.amber)
                        .offset(x: 20, y: -19)
                }
                .frame(width: 64, height: 64)
                .hindsightShadow(HindsightTheme.Shadows.glow)
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text("HINDSIGHT")
                        .font(HindsightTheme.Typography.metadata)
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .tracking(1.2)
                    Text("Your personal signal")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                }
            }

            Text("See how your confidence compares with reality.")
                .font(HindsightTheme.Typography.editorialDisplay)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Capture what you believe before the answer is known. Resolve it later. Hindsight turns those moments into a colorful, honest picture of how you make decisions.")
                .font(HindsightTheme.Typography.body)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            conceptRow(
                number: "01",
                title: "Capture",
                detail: "Write one belief while the outcome is still uncertain.",
                icon: "lightbulb.max.fill",
                color: HindsightTheme.Colors.categoryPersonal
            )
            conceptRow(
                number: "02",
                title: "Choose your certainty",
                detail: "Move a 0–100 slider. No confidence is assumed for you.",
                icon: "dial.medium.fill",
                color: HindsightTheme.Colors.categoryEducation
            )
            conceptRow(
                number: "03",
                title: "Meet reality",
                detail: "Resolve it honestly and watch your personal patterns emerge.",
                icon: "sparkles",
                color: HindsightTheme.Colors.success
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("How Hindsight works")
    }

    private func conceptRow(number: String, title: String, detail: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                    .fill(color.opacity(0.15))
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            .frame(width: 46, height: 46)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                HStack(spacing: 6) {
                    Text(number)
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(color)
                    Text(title)
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                }
                Text(detail)
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .stroke(color.opacity(0.20), lineWidth: 1)
        }
    }

    private var illustrativeInsight: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [HindsightTheme.Colors.categoryPersonal, HindsightTheme.Colors.accent, HindsightTheme.Colors.categoryEducation],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 180, height: 180)
                .offset(x: 56, y: -70)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                Label("A GLIMPSE OF YOUR FUTURE INSIGHTS", systemImage: "chart.xyaxis.line")
                    .font(HindsightTheme.Typography.metadata)
                    .foregroundStyle(.white.opacity(0.86))

                Text("When you felt 80%+ sure, reality agreed 75% of the time.")
                    .font(HindsightTheme.Typography.title)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: HindsightTheme.Spacing.sm) {
                    insightPill("8 forecasts", icon: "number")
                    insightPill("6 happened", icon: "checkmark")
                }

                Text("Illustrative example only. Your app waits for enough eligible personal outcomes, shows the denominator, and excludes sample records.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HindsightTheme.Spacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous))
        .hindsightShadow(HindsightTheme.Shadows.glow)
        .accessibilityElement(children: .combine)
    }

    private func insightPill(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(HindsightTheme.Typography.caption2)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .frame(minHeight: 30)
            .background(.white.opacity(0.14), in: Capsule())
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            Text("Ready to learn your signal?")
                .font(HindsightTheme.Typography.title2)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)

            onboardingAction(
                title: "Capture my first belief",
                detail: "Start with something you can check tomorrow or this week.",
                icon: "sparkles",
                style: .primary,
                action: { finish(.firstForecast) }
            )
            onboardingAction(
                title: "Explore example records",
                detail: "See the flow with clearly marked samples that never affect your insights.",
                icon: "wand.and.stars",
                style: .secondary,
                action: { finish(.exampleData) }
            )
            onboardingAction(
                title: "Start empty",
                detail: "Go to Today without adding anything.",
                icon: "arrow.right",
                style: .secondary,
                action: { finish(.empty) }
            )
        }
    }

    private func onboardingAction(
        title: String,
        detail: String,
        icon: String,
        style: OnboardingActionStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: HindsightTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(style.iconBackground)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(style.iconForeground)
                }
                .frame(width: 40, height: 40)
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                    Text(title)
                        .font(HindsightTheme.Typography.headline)
                    Text(detail)
                        .font(HindsightTheme.Typography.footnote)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: HindsightTheme.Spacing.sm)
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(style.foreground)
            .padding(HindsightTheme.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .stroke(style.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint(detail)
    }

    private var privacyNote: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(HindsightTheme.Colors.success)
                .accessibilityHidden(true)
            Text("Private on this device. No account, public profile, ads, or tracking.")
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.success.opacity(0.10), in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
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
        case .primary: .white
        case .secondary: HindsightTheme.Colors.textPrimary
        }
    }

    var background: Color {
        switch self {
        case .primary: HindsightTheme.Colors.accent
        case .secondary: HindsightTheme.Colors.card
        }
    }

    var border: Color {
        switch self {
        case .primary: HindsightTheme.Colors.accent
        case .secondary: HindsightTheme.Colors.borderStrong
        }
    }

    var iconBackground: Color {
        switch self {
        case .primary: .white.opacity(0.18)
        case .secondary: HindsightTheme.Colors.categoryPersonal.opacity(0.14)
        }
    }

    var iconForeground: Color {
        switch self {
        case .primary: .white
        case .secondary: HindsightTheme.Colors.categoryPersonal
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
        HindsightTheme.Colors.backgroundGradient
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
        kind == .primary ? .white : HindsightTheme.Colors.textPrimary
    }

    private var background: Color {
        switch kind {
        case .primary: HindsightTheme.Colors.accent
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
