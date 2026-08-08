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
    @State private var bootResult: Result<ModelContainer, Error>?

    /// One shared, on-disk SwiftData container for the whole app, if successful.
    private var modelContainer: ModelContainer? {
        if case .success(let container) = bootResult {
            return container
        }
        return nil
    }

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
            defaults.removeObject(forKey: AppStorageKeys.quickCaptureDraft)
        }

        // Built locally and handed to `_bootResult`'s initial value below.
        // Assigning through `self.bootResult = ...` from inside init() does
        // NOT reliably reach the storage `body` reads: SwiftUI only wires up
        // @State's backing box once view identity is established, so a plain
        // property write during init() can target a transient copy and
        // silently vanish — leaving `body` stuck on `nil` forever, which
        // renders as a black screen with the defensive ProgressView.
        // (Writing `self.bootResult` from retryBootstrap() below is fine:
        // by then the view exists and @State behaves normally.)
        let result: Result<ModelContainer, Error>
        do {
            if Self.isUITesting {
                let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                result = .success(try StoreBootstrap.makeContainer(configuration: config))
            } else {
                result = .success(try StoreBootstrap.makeContainer())
            }
        } catch {
            result = .failure(error)
        }
        _bootResult = State(initialValue: result)

        // Default review reminders + haptics to ON so they work before the
        // user ever visits Settings.
        UserDefaults.standard.register(defaults: [
            AppStorageKeys.reviewReminders: true,
            AppStorageKeys.hapticsEnabled: true
        ])
        Appearance.configure()
    }

    /// A Debug-only UI-test seam. In Release this is compiled as a constant
    /// `false`, so launch arguments can never opt a distributable build into
    /// its in-memory store or test defaults.
    #if DEBUG
    private static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTestReset")
    }
    #else
    private static let isUITesting = false
    #endif

    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                HindsightRootView()
                    .environmentObject(notificationManager)
                    .tint(HindsightTheme.Colors.accent)
                    .preferredColorScheme(.dark)
                    .modelContainer(container)
            } else if case .failure(let error) = bootResult {
                StoreRecoveryView(error: error, onRetry: { retryBootstrap() })
                    .tint(HindsightTheme.Colors.accent)
                    .preferredColorScheme(.dark)
            } else {
                // Loading state (shouldn't occur in practice, but defensive)
                ProgressView()
                    .preferredColorScheme(.dark)
            }
        }
    }

    private func retryBootstrap() {
        do {
            if Self.isUITesting {
                let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                self.bootResult = .success(try StoreBootstrap.makeContainer(configuration: config))
            } else {
                self.bootResult = .success(try StoreBootstrap.makeContainer())
            }
        } catch {
            self.bootResult = .failure(error)
        }
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
