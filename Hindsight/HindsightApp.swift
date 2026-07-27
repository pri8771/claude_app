//
//  HindsightApp.swift
//  Hindsight
//
//  A private decision journal that runs 100% on-device.
//  "Remember what you believed before reality gave you the answer."
//

import SwiftUI
import SwiftData
import UIKit

@main
struct HindsightApp: App {
    @StateObject private var notificationManager = NotificationManager.shared

    /// One shared, on-disk SwiftData container for the whole app.
    let modelContainer: ModelContainer

    init() {
        if Self.isUITesting {
            // Deterministic, isolated state for the UI test target: an
            // in-memory store (never touches the developer's real on-disk
            // data), onboarding pre-completed, and reminders off so a
            // system notification-permission prompt can never interrupt an
            // automated run.
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: AppStorageKeys.hasCompletedOnboarding)
            defaults.set(false, forKey: AppStorageKeys.reviewReminders)
            defaults.set(true, forKey: AppStorageKeys.hapticsEnabled)
            defaults.set(true, forKey: AppStorageKeys.hasLaunchedBefore)
            defaults.set(true, forKey: AppStorageKeys.didRequestNotifications)
        }

        do {
            let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
            if Self.isUITesting {
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(for: schema, configurations: [config])
            } else {
                modelContainer = try ModelContainer(for: schema)
            }
        } catch {
            fatalError("Failed to create the SwiftData container: \(error)")
        }
        // Default review reminders + haptics to ON so they work before the
        // user ever visits Settings.
        UserDefaults.standard.register(defaults: [
            AppStorageKeys.reviewReminders: true,
            AppStorageKeys.hapticsEnabled: true
        ])
        Appearance.configure()
    }

    /// True when launched by the `HindsightUITests` target.
    private static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTestReset")
    }

    var body: some Scene {
        WindowGroup {
            HindsightRootView()
                .environmentObject(notificationManager)
                .tint(HindsightTheme.Colors.accent)
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - UIKit appearance

/// Configures navigation / tab bar chrome to match the dark theme.
private enum Appearance {
    static func configure() {
        let background = UIColor(HindsightTheme.Colors.background)

        // Navigation bar
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = background
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: UIColor.white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        // Tab bar
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(HindsightTheme.Colors.surface)
        tab.shadowColor = UIColor.white.withAlphaComponent(0.06)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}
