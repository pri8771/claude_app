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
        do {
            modelContainer = try ModelContainer(
                for: Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self
            )
        } catch {
            fatalError("Failed to create the SwiftData container: \(error)")
        }
        // Default review reminders to ON so the very first decision schedules
        // a reminder before the user ever visits Settings.
        UserDefaults.standard.register(defaults: [AppStorageKeys.reviewReminders: true])
        Appearance.configure()
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
