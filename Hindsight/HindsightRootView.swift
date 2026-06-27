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
}

struct HindsightRootView: View {
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @StateObject private var router = AppRouter()

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
    }
}

#Preview("Onboarding") {
    HindsightRootView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
