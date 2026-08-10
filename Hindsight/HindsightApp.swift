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
            if Self.shouldResetUITestState {
                defaults.removeObject(forKey: AppStorageKeys.quickCaptureDraft)
                defaults.removeObject(forKey: AppStorageKeys.didCompleteQuickCaptureNudge)
                OutcomeReviewDraftStore.clearAll(defaults: defaults)
                PredictionResolutionDraftStore.clearAll(defaults: defaults)
            }
            defaults.set(MainTabView.Tab.now.rawValue, forKey: AppStorageKeys.selectedMainTab)
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
            result = .success(try Self.makeContainer())
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
    private static var isUITesting: Bool { usesInMemoryUITestStore || usesFileBackedUITestStore }
    private static var shouldResetUITestState: Bool {
        usesInMemoryUITestStore || ProcessInfo.processInfo.arguments.contains("-uiTestFileBackedReset")
    }
    private static var usesInMemoryUITestStore: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTestReset")
    }
    private static var usesFileBackedUITestStore: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTestFileBacked") ||
        ProcessInfo.processInfo.arguments.contains("-uiTestFileBackedReset")
    }
    #else
    private static let isUITesting = false
    private static let shouldResetUITestState = false
    #endif

    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                HindsightRootView()
                    .environmentObject(notificationManager)
                    .tint(HindsightTheme.Colors.accent)
                    .modelContainer(container)
            } else if case .failure(let error) = bootResult {
                StoreRecoveryView(error: error, onRetry: { retryBootstrap() })
                    .tint(HindsightTheme.Colors.accent)
            } else {
                // Loading state (shouldn't occur in practice, but defensive)
                ProgressView()
            }
        }
    }

    private func retryBootstrap() {
        do {
            self.bootResult = .success(try Self.makeContainer())
        } catch {
            self.bootResult = .failure(error)
        }
    }

    private static func makeContainer() throws -> ModelContainer {
        #if DEBUG
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        if usesInMemoryUITestStore {
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try StoreBootstrap.makeContainer(configuration: configuration)
        }
        if usesFileBackedUITestStore {
            let storeURL = uiTestStoreURL
            if shouldResetUITestState {
                for url in [storeURL,
                            URL(fileURLWithPath: storeURL.path + "-wal"),
                            URL(fileURLWithPath: storeURL.path + "-shm")] {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            let configuration = ModelConfiguration(schema: schema, url: storeURL)
            return try StoreBootstrap.makeContainer(configuration: configuration)
        }
        #endif
        return try StoreBootstrap.makeContainer()
    }

    #if DEBUG
    private static var uiTestStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent("hindsight-ui-test.store")
    }
    #endif
}

// MARK: - UIKit appearance

/// Configures navigation and tab chrome for the adaptive adult visual system.
private enum Appearance {
    static func configure() {
        let background = UIColor(HindsightTheme.Colors.surface)
        let ink = UIColor(HindsightTheme.Colors.textPrimary)

        // Navigation bar
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = background
        nav.shadowColor = .clear
        nav.titleTextAttributes = [.foregroundColor: ink]
        nav.largeTitleTextAttributes = [.foregroundColor: ink]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        // Tab bar
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(HindsightTheme.Colors.surface)
        tab.shadowColor = UIColor(HindsightTheme.Colors.border)
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
    }
}
