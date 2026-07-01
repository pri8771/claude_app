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
    /// Set when a local reminder is tapped and the Decisions tab should open
    /// a specific decision detail screen.
    @Published var focusDecisionID: UUID?
}

struct HindsightRootView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @StateObject private var router = AppRouter()

    @State private var showSplash = true

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .environmentObject(router)
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        // Branded launch animation that fades into the app.
        .overlay {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_300_000_000)
            withAnimation(.easeInOut(duration: 0.45)) { showSplash = false }
        }
    }
}

#Preview("Onboarding") {
    HindsightRootView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
