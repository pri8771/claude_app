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
import os

@main
struct HindsightApp: App {
    // The notification manager is a process-lifetime singleton; we hold a
    // plain reference and inject it, rather than letting @StateObject imply
    // SwiftUI owns its lifecycle.
    private let notificationManager = NotificationManager.shared

    /// One shared SwiftData container for the whole app.
    let modelContainer: ModelContainer
    /// True when the on-disk store couldn't be opened and we fell back to an
    /// in-memory store (so the app stays usable and can warn the user).
    let usingFallbackStore: Bool

    init() {
        let models: [any PersistentModel.Type] = [
            Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self
        ]
        let schema = Schema(models)
        let log = Logger(subsystem: "com.hindsight.app", category: "storage")

        if let container = try? ModelContainer(for: schema) {
            modelContainer = container
            usingFallbackStore = false
        } else {
            // On-disk store failed (e.g. an incompatible migration). Rather
            // than crash, fall back to an in-memory store so the app launches
            // and the user keeps access to the UI.
            log.error("On-disk store unavailable; falling back to in-memory store.")
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            guard let fallback = try? ModelContainer(for: schema, configurations: [config]) else {
                fatalError("Failed to create even an in-memory SwiftData container.")
            }
            modelContainer = fallback
            usingFallbackStore = true
        }

        // Default review reminders + haptics to ON so they work before the
        // user ever visits Settings.
        UserDefaults.standard.register(defaults: [
            AppStorageKeys.reviewReminders: true,
            AppStorageKeys.hapticsEnabled: true
        ])
        Appearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            HindsightRootView(usingFallbackStore: usingFallbackStore)
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
