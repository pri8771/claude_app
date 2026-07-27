//
//  OnboardingView.swift
//  Hindsight
//
//  First-run onboarding: a 4-page, warm, cinematic introduction to a
//  private decision time capsule. Fully local — no accounts, no network.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Onboarding palette

/// A warm, slightly cinematic palette for onboarding. Kept self-contained
/// so the rest of the app's theme is untouched.
enum OnboardingTheme {
    enum Colors {
        static let background    = Color(hex: "1A1A2E")
        static let accent        = Color(hex: "E94560")
        static let amber         = Color(hex: "F5A623")
        static let card          = Color(hex: "242442")
        static let elevated      = Color(hex: "2E2E50")
        static let textPrimary   = Color(hex: "F7F7FB")
        static let textSecondary = Color(hex: "A7A7C7")
        static let border        = Color(hex: "343456")
    }
}

// MARK: - Root onboarding view

struct OnboardingView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var router: AppRouter

    @State private var page = 0
    private let pageCount = 4

    enum Finish { case firstDecision, sampleData, empty }

    var body: some View {
        ZStack {
            OnboardingBackground(page: page).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                pages
                bottomBar
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Top bar (Back appears after page 1)

    private var topBar: some View {
        HStack {
            Button(action: goBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(OnboardingTheme.Colors.textSecondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(OnboardingTheme.Colors.elevated.opacity(0.6), in: Capsule())
            }
            .opacity(page > 0 ? 1 : 0)
            .disabled(page == 0)
            .animation(.easeInOut(duration: 0.2), value: page)

            Spacer()
        }
        .padding(.horizontal, HindsightTheme.Spacing.lg)
        .padding(.top, HindsightTheme.Spacing.sm)
        .frame(height: 44)
    }

    // MARK: Paged content

    private var pages: some View {
        TabView(selection: $page) {
            OnboardingPageView(
                iconCluster: ["clock.arrow.circlepath", "lock.shield", "doc.text"],
                eyebrow: nil,
                title: "Hindsight",
                isBrandTitle: true,
                subtitle: "Your private decision time machine.",
                message: "Record what you believe before reality gives you the answer."
            ) { EmptyView() }
                .tag(0)

            OnboardingPageView(
                iconCluster: ["lock.shield.fill"],
                eyebrow: "Private by design",
                title: "What you write stays yours",
                subtitle: nil,
                message: "No account. No server. Your decisions stay on this device."
            ) { OnboardingPrivacyCard() }
                .tag(1)

            OnboardingPageView(
                iconCluster: ["arrow.triangle.2.circlepath"],
                eyebrow: "How it works",
                title: "Build better judgment",
                subtitle: nil,
                message: "Capture a belief now, then let future-you check the receipts."
            ) { OnboardingDecisionLoopView() }
                .tag(2)

            OnboardingFinalCTAView(
                onFirstDecision: { finish(.firstDecision) },
                onSampleData:    { finish(.sampleData) },
                onEmpty:         { finish(.empty) }
            )
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: page)
        // Onboarding page swipe / advance (moment #10).
        .haptics(.light, trigger: page)
    }

    // MARK: Bottom bar (dots + Continue)

    private var bottomBar: some View {
        VStack(spacing: HindsightTheme.Spacing.lg) {
            if page < pageCount - 1 {
                OnboardingButton(title: "Continue", icon: "arrow.right", kind: .primary, action: advance)
                    .padding(.horizontal, HindsightTheme.Spacing.lg)
                    .transition(.opacity)
            }
            OnboardingProgressDotsView(count: pageCount, index: page)
        }
        .padding(.bottom, HindsightTheme.Spacing.lg)
        .padding(.top, HindsightTheme.Spacing.sm)
        .animation(.easeInOut(duration: 0.25), value: page)
    }

    // MARK: Actions

    private func advance() {
        // Page-change haptic is fired by `.haptics(.light, trigger: page)`.
        withAnimation(.easeInOut) { page = min(page + 1, pageCount - 1) }
    }

    private func goBack() {
        withAnimation(.easeInOut) { page = max(page - 1, 0) }
    }

    private func finish(_ kind: Finish) {
        switch kind {
        case .firstDecision: router.presentNewDecision = true
        case .sampleData:    SampleData.insertIfMissing(into: context)
        case .empty:         break
        }
        HapticsManager.shared.onboardingCompleted()
        withAnimation(.easeInOut(duration: 0.35)) { hasCompletedOnboarding = true }
    }
}

// MARK: - Cinematic background

/// Soft, layered, performant gradients + a single blurred accent blob that
/// drifts as the page changes.
struct OnboardingBackground: View {
    let page: Int

    var body: some View {
        ZStack {
            OnboardingTheme.Colors.background

            RadialGradient(
                colors: [OnboardingTheme.Colors.accent.opacity(0.26), .clear],
                center: .topTrailing, startRadius: 8, endRadius: 460
            )
            RadialGradient(
                colors: [OnboardingTheme.Colors.amber.opacity(0.14), .clear],
                center: .bottomLeading, startRadius: 8, endRadius: 480
            )

            Circle()
                .fill(OnboardingTheme.Colors.accent.opacity(0.12))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: page.isMultiple(of: 2) ? -130 : 130,
                        y: CGFloat(page) * 44 - 150)
                .animation(.easeInOut(duration: 0.7), value: page)

            // A subtle vignette to deepen the journal feel.
            RadialGradient(
                colors: [.clear, OnboardingTheme.Colors.background.opacity(0.55)],
                center: .center, startRadius: 220, endRadius: 620
            )
        }
    }
}

// MARK: - Shared onboarding button

struct OnboardingButton: View {
    enum Kind { case primary, secondary, tertiary }

    let title: String
    var icon: String? = nil
    var kind: Kind = .primary
    let action: () -> Void

    var body: some View {
        Button {
            // Haptics for onboarding are handled centrally: page changes via
            // `.haptics(trigger: page)`, completion via `onboardingCompleted()`.
            action()
        } label: {
            HStack(spacing: HindsightTheme.Spacing.sm) {
                Text(title)
                if let icon { Image(systemName: icon).font(.body.weight(.bold)) }
            }
            .font(.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background { background }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch kind {
        case .primary:   return .white
        case .secondary: return OnboardingTheme.Colors.textPrimary
        case .tertiary:  return OnboardingTheme.Colors.textSecondary
        }
    }

    @ViewBuilder private var background: some View {
        switch kind {
        case .primary:
            LinearGradient(colors: [OnboardingTheme.Colors.accent, Color(hex: "C2334B")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .secondary:
            OnboardingTheme.Colors.elevated
        case .tertiary:
            Color.clear
        }
    }

    private var borderColor: Color {
        switch kind {
        case .primary:   return .clear
        case .secondary: return OnboardingTheme.Colors.border
        case .tertiary:  return .clear
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppRouter())
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
