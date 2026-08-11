//
//  HindsightRootView.swift
//  Hindsight
//
//  The app's root. Gates first-run onboarding in front of the main app
//  based on the `hasCompletedOnboarding` flag, and owns a lightweight
//  router so onboarding can deep-link into the main app (e.g. open the
//  New Decision flow).
//

import SwiftUI

/// Cross-cutting navigation intents that survive the onboarding → main
/// app view swap. Kept intentionally tiny and local-only.
@MainActor
final class AppRouter: ObservableObject {
    /// When set, the main app presents the New Decision wizard.
    @Published var presentNewDecision = false
    /// When set, the main app presents the one-screen forecast capture flow.
    @Published var presentQuickCapture = false
    /// Set when a local reminder is tapped and the Decisions tab should open
    /// a specific decision detail screen.
    @Published var focusDecisionID: UUID?
}

struct HindsightRootView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @StateObject private var router = AppRouter()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            SignalGardenBackground()

            if hasCompletedOnboarding {
                MainTabView()
                    .transition(rootTransition)
            } else {
                OnboardingView()
                    .transition(rootTransition)
            }
        }
        .environmentObject(router)
        .tint(HindsightTheme.Colors.accent)
        .animation(reduceMotion ? nil : HindsightTheme.Motion.gentle, value: hasCompletedOnboarding)
    }

    private var rootTransition: AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.985))
    }
}

#Preview("Onboarding") {
    HindsightRootView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
