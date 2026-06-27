//
//  ContentView.swift
//  Hindsight
//
//  Root tab bar: Today, Decisions, Insights and Settings.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @AppStorage(AppStorageKeys.didRequestNotifications) private var didRequestNotifications = false

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
        .task {
            // Ask for notification permission once, on first launch.
            if !didRequestNotifications {
                didRequestNotifications = true
                _ = await notificationManager.requestAuthorization()
            } else {
                await notificationManager.refreshAuthorizationStatus()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
