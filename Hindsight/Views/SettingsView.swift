//
//  SettingsView.swift
//  Hindsight
//
//  Profile, notifications, privacy statement, data export and the
//  destructive "clear all data" action.
//

import SwiftUI
import SwiftData
import UserNotifications
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query private var decisions: [Decision]

    @AppStorage(AppStorageKeys.reviewReminders) private var reviewReminders = true
    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(AppStorageKeys.hapticsEnabled) private var hapticsEnabled = true

    @State private var shareURL: ShareItem?
    @State private var showClearConfirm = false
    @State private var showRemoveDemoConfirm = false
    @State private var exportError: String?
    @State private var clearError: String?
    @State private var sampleRemovalError: String?
    @State private var sampleInsertionError: String?

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HindsightTheme.Spacing.lg) {
                        privacyCard
                        notificationSection
                        hapticsSection
                        dataSection
                        helpSection
                        dangerSection
                        aboutSection
                        Color.clear.frame(height: 24)
                    }
                    .padding(HindsightTheme.Spacing.md)
                    .hindsightReadableWidth()
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(item: $shareURL) { item in
                ShareSheet(items: [item.url])
            }
            .alert("Export failed", isPresented: Binding(
                get: { exportError != nil }, set: { if !$0 { exportError = nil } }
            )) {
                Button("OK", role: .cancel) { exportError = nil }
            } message: { Text(exportError ?? "") }
            .confirmationDialog("Delete everything?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Delete all data", role: .destructive) { clearAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently erases all \(decisions.count) decisions, predictions and reviews. This can't be undone.")
            }
            .confirmationDialog("Remove example records?", isPresented: $showRemoveDemoConfirm, titleVisibility: .visible) {
                Button("Remove example records", role: .destructive) {
                    removeDemoData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your own decisions will be kept.")
            }
            .alert("Couldn't delete data", isPresented: Binding(
                get: { clearError != nil }, set: { if !$0 { clearError = nil } }
            )) {
                Button("Try Again") { clearAllData() }
                Button("Cancel", role: .cancel) { clearError = nil }
            } message: { Text(clearError ?? "An error occurred while deleting your data.") }
            .alert("Couldn't remove example records", isPresented: Binding(
                get: { sampleRemovalError != nil }, set: { if !$0 { sampleRemovalError = nil } }
            )) {
                Button("Try Again") { removeDemoData() }
                Button("Cancel", role: .cancel) { sampleRemovalError = nil }
            } message: { Text(sampleRemovalError ?? "Your data is still here. Please try again.") }
            .alert("Couldn't load example records", isPresented: Binding(
                get: { sampleInsertionError != nil }, set: { if !$0 { sampleInsertionError = nil } }
            )) {
                Button("Try Again") { loadExampleData() }
                Button("Cancel", role: .cancel) { sampleInsertionError = nil }
            } message: { Text(sampleInsertionError ?? "Nothing was added. Please try again.") }
            .task { await notificationManager.refreshAuthorizationStatus() }
        }
    }

    // MARK: Privacy card

    private var privacyCard: some View {
        HCard(background: HindsightTheme.Colors.success.opacity(0.10)) {
            HStack(spacing: HindsightTheme.Spacing.md) {
                ZStack {
                    Circle().fill(HindsightTheme.Colors.success.opacity(0.18)).frame(width: 48, height: 48)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(HindsightTheme.Colors.success)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your decisions never leave this device")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("100% on-device. No account, no cloud, no tracking.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
        }
    }

    // MARK: Notifications

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Reminders", systemImage: "bell.fill")
            HCard {
                VStack(spacing: HindsightTheme.Spacing.md) {
                    Toggle(isOn: $reviewReminders) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Review reminders")
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            Text("Get nudged when it's time to look back.")
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                    }
                    .tint(HindsightTheme.Colors.accent)
                    .onChange(of: reviewReminders) { _, enabled in
                        handleReminderToggle(enabled)
                    }

                    if notificationManager.authorizationStatus == .denied {
                        Divider().overlay(HindsightTheme.Colors.border)
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(HindsightTheme.Colors.amber)
                            Text("Notifications are disabled in iOS Settings.")
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            Spacer()
                            Button("Open") { openSystemSettings() }
                                .font(HindsightTheme.Typography.caption)
                                .tint(HindsightTheme.Colors.accent)
                        }
                    }
                }
            }
        }
    }

    // MARK: Data

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Your data", systemImage: "externaldrive.fill")
            HCard {
                VStack(spacing: HindsightTheme.Spacing.sm) {
                    settingsRow(icon: "doc.badge.arrow.up", tint: HindsightTheme.Colors.accent,
                                title: "Export as JSON", subtitle: "Machine-readable backup") {
                        exportJSON()
                    }
                    Divider().overlay(HindsightTheme.Colors.border)
                    settingsRow(icon: "doc.richtext", tint: HindsightTheme.Colors.amber,
                                title: "Export as PDF", subtitle: "Printable journal report") {
                        exportPDF()
                    }
                    Divider().overlay(HindsightTheme.Colors.border)
                    settingsRow(
                        icon: hasDemoData ? "trash.slash" : "wand.and.stars",
                        tint: HindsightTheme.Colors.success,
                        title: hasDemoData ? "Remove example records" : "Explore example records",
                        subtitle: hasDemoData ? "Keep your records; remove only examples" : "Clearly labeled and excluded from personal insights"
                    ) {
                        if hasDemoData {
                            showRemoveDemoConfirm = true
                        } else {
                            loadExampleData()
                        }
                    }
                }
            }
        }
    }

    // MARK: Haptics

    private var hapticsSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Feedback", systemImage: "hand.tap.fill")
            HCard {
                Toggle(isOn: $hapticsEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptic feedback")
                            .font(HindsightTheme.Typography.headline)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        Text("Subtle taps as you capture, resolve and review.")
                            .font(HindsightTheme.Typography.caption)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                }
                .tint(HindsightTheme.Colors.accent)
                .onChange(of: hapticsEnabled) { _, enabled in
                    // Give immediate confirmation when switching on.
                    if enabled { HapticsManager.shared.selectionChanged() }
                }
            }
        }
    }

    // MARK: Help

    private var helpSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Help", systemImage: "questionmark.circle.fill")
            HCard {
                settingsRow(icon: "sparkles", tint: HindsightTheme.Colors.amber,
                            title: "Show onboarding again",
                            subtitle: "Replay the intro — your data is kept") {
                    hasCompletedOnboarding = false
                }
            }
        }
    }

    // MARK: Danger

    private var dangerSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Delete data", systemImage: "exclamationmark.octagon.fill",
                           tint: HindsightTheme.Colors.accent)
            HButton(title: "Clear all data", icon: "trash", style: .destructive) {
                showClearConfirm = true
            }
        }
    }

    // MARK: About

    private var aboutSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 28))
                .foregroundStyle(HindsightTheme.Colors.accent)
            Text("Hindsight")
                .font(HindsightTheme.Typography.headline)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text("Remember what you believed before reality gave you the answer.")
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Text("Version \(ExportManager.appVersion)")
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, HindsightTheme.Spacing.md)
    }

    // MARK: Row helper

    private func settingsRow(icon: String, tint: Color, title: String, subtitle: String,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: HindsightTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                        .fill(tint.opacity(0.16)).frame(width: 36, height: 36)
                    Image(systemName: icon).foregroundStyle(tint).font(.system(size: 16, weight: .semibold))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text(subtitle).font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            }
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    // MARK: Actions

    private var hasDemoData: Bool {
        decisions.contains(where: SampleData.isDemoDecision)
    }

    private func handleReminderToggle(_ enabled: Bool) {
        Task {
            if enabled {
                let granted = await notificationManager.requestAuthorization()
                if granted {
                    notificationManager.rescheduleAll(
                        for: NotificationManager.decisionsEligibleForRescheduling(decisions)
                    )
                }
            } else {
                notificationManager.cancelAll()
            }
        }
    }

    private func exportJSON() {
        do { shareURL = ShareItem(url: try ExportManager.exportJSON(decisions)) }
        catch { exportError = "Couldn't create the JSON file." }
    }

    private func exportPDF() {
        do { shareURL = ShareItem(url: try ExportManager.exportPDF(decisions)) }
        catch { exportError = "Couldn't create the PDF file." }
    }

    private func clearAllData() {
        if DataLifecycleManager.deleteAllJournalData(decisions, in: context) {
            notificationManager.cancelAll()
            HapticsManager.shared.deleteConfirmed()
        } else {
            clearError = "An error occurred while deleting your data."
        }
    }

    private func removeDemoData() {
        switch SampleData.remove(from: context) {
        case .success(let removedCount):
            if removedCount > 0 {
                HapticsManager.shared.deleteConfirmed()
            }
        case .failed:
            sampleRemovalError = "Your example and personal records are still here. Please try again."
        }
    }

    private func loadExampleData() {
        if SampleData.insertIfMissing(into: context) || SampleData.containsDemoData(in: context) {
            sampleInsertionError = nil
            HapticsManager.shared.selectionChanged()
        } else {
            sampleInsertionError = "The example records could not be saved. Your existing data is unchanged."
        }
    }

    private func openSystemSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}

// MARK: - Share sheet plumbing

/// Identifiable wrapper so a file URL can drive a `.sheet(item:)`.
struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
