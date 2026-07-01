//
//  MainTabView.swift
//  Hindsight
//
//  The app's main tab bar: Today, Decisions, Insights and Settings.
//  Shown once first-run onboarding is complete (see HindsightRootView).
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var router: AppRouter

    @State private var selectedTab: Tab = .today

    enum Tab: Hashable { case today, decisions, insights, settings }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "house.fill") }
                .tag(Tab.today)

            AllDecisionsView()
                .tabItem { Label("Decisions", systemImage: "books.vertical.fill") }
                .tag(Tab.decisions)

            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.fill") }
                .tag(Tab.insights)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .tint(HindsightTheme.Colors.accent)
        // Tab switch (moment #12) — very subtle selection feedback.
        .haptics(.selection, trigger: selectedTab)
        // Deep-link target for onboarding's "Start First Decision" path.
        .sheet(isPresented: $router.presentNewDecision) {
            NewDecisionWizard()
        }
        .task {
            await notificationManager.refreshAuthorizationStatus()
        }
        .onChange(of: notificationManager.tappedDecisionID) { _, decisionID in
            guard let decisionID else { return }
            selectedTab = .decisions
            router.focusDecisionID = decisionID
            notificationManager.tappedDecisionID = nil
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(NotificationManager.shared)
        .environmentObject(AppRouter())
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
