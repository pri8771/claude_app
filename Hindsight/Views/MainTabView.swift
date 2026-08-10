//
//  MainTabView.swift
//  Hindsight
//
//  The adult personal shell: Today, History, one-tap Capture, Insights and Settings.
//  Shown once first-run onboarding is complete (see HindsightRootView).
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var router: AppRouter

    @AppStorage(AppStorageKeys.selectedMainTab) private var selectedTabRaw = Tab.now.rawValue

    enum Tab: String, Hashable {
        case now
        case hindsight
        case capture
        case insights
        case settings
    }

    var body: some View {
        TabView(selection: tabSelection) {
            TodayView()
                .tabItem { Label("Today", systemImage: "calendar") }
                .tag(Tab.now)

            HindsightArchiveView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.hindsight)

            Color.clear
                .tabItem { Label("Capture", systemImage: "plus.circle.fill") }
                .tag(Tab.capture)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.xyaxis.line") }
                .tag(Tab.insights)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .tint(HindsightTheme.Colors.accent)
        .toolbarBackground(HindsightTheme.Colors.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        // Tab switch (moment #12) — very subtle selection feedback.
        .haptics(.selection, trigger: selectedTabRaw)
        .sheet(isPresented: $router.presentQuickCapture) {
            QuickCaptureSheet()
        }
        // Deep-link target for onboarding's "Start First Decision" path.
        .sheet(isPresented: $router.presentNewDecision) {
            NewDecisionWizard()
        }
        .task {
            await notificationManager.refreshAuthorizationStatus()
            // Handle cold-launch notification deep link
            if let decisionID = notificationManager.tappedDecisionID {
                route(to: decisionID)
            }
        }
        .onChange(of: notificationManager.tappedDecisionID) { _, decisionID in
            guard let decisionID else { return }
            route(to: decisionID)
        }
    }

    private var tabSelection: Binding<Tab> {
        Binding(
            get: { Tab(rawValue: selectedTabRaw) ?? .now },
            set: { newValue in
                if newValue == .capture {
                    router.presentQuickCapture = true
                } else {
                    selectedTabRaw = newValue.rawValue
                }
            }
        )
    }

    private func route(to decisionID: UUID) {
        selectedTabRaw = Tab.now.rawValue
        router.focusDecisionID = decisionID
        notificationManager.tappedDecisionID = nil
    }
}

#Preview {
    MainTabView()
        .environmentObject(NotificationManager.shared)
        .environmentObject(AppRouter())
        .modelContainer(SampleData.previewContainer)
}
