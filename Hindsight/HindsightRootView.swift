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
    /// True when the app is running on a temporary in-memory store because
    /// the persistent store couldn't be opened (see `HindsightApp`).
    var usingFallbackStore: Bool = false

    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @StateObject private var router = AppRouter()

    @State private var showSplash = true
    @State private var showStoreWarning = false

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
        .alert("Storage unavailable", isPresented: $showStoreWarning) {
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Hindsight couldn't open your saved data, so it's running in temporary mode. Anything you add now won't be saved. Reinstalling the app usually fixes this.")
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_300_000_000)
            withAnimation(.easeInOut(duration: 0.45)) { showSplash = false }
            if usingFallbackStore { showStoreWarning = true }
        }
    }
}

#Preview("Onboarding") {
    HindsightRootView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
