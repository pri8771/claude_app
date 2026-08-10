//
//  StoreRecoveryView.swift
//  Hindsight
//
//  Shown when the on-disk SwiftData store fails to open. Store files are
//  left untouched unless the user explicitly chooses to reset. Offers
//  retry, export-for-support, and a double-confirmed destructive reset.
//

import SwiftUI

struct StoreRecoveryView: View {
    let error: Error
    let onRetry: () -> Void

    @State private var showShareSheet = false
    @State private var shareURLs: [URL] = []
    @State private var showResetConfirm1 = false
    @State private var showResetConfirm2 = false
    @State private var exportError: String?

    var body: some View {
        ZStack {
            HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: HindsightTheme.Spacing.lg) {
                    Spacer(minLength: HindsightTheme.Spacing.xl)

                    ZStack {
                        Circle()
                            .fill(HindsightTheme.Colors.accent.opacity(0.16))
                            .frame(width: 72, height: 72)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(HindsightTheme.Colors.accent)
                    }

                    VStack(spacing: 6) {
                        Text("Hindsight couldn't open your data")
                            .font(HindsightTheme.Typography.title2)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        Text("Your decisions haven't been touched or deleted. Try again, or export your files before resetting.")
                            .font(HindsightTheme.Typography.subheadline)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, HindsightTheme.Spacing.lg)

                    HCard {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ERROR DETAIL")
                                .font(HindsightTheme.Typography.caption2)
                                .foregroundStyle(HindsightTheme.Colors.textTertiary)
                            Text(error.localizedDescription)
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(spacing: HindsightTheme.Spacing.sm) {
                        HButton(title: "Retry", icon: "arrow.clockwise", style: .primary) {
                            onRetry()
                        }
                        HButton(title: "Export data files", icon: "square.and.arrow.up", style: .secondary) {
                            exportStoreFiles()
                        }
                        HButton(title: "Reset app data", icon: "trash", style: .destructive) {
                            showResetConfirm1 = true
                        }
                    }

                    Spacer(minLength: HindsightTheme.Spacing.xl)
                }
                .padding(HindsightTheme.Spacing.md)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareURLs)
        }
        .alert("Couldn't export", isPresented: Binding(
            get: { exportError != nil }, set: { if !$0 { exportError = nil } }
        )) {
            Button("OK", role: .cancel) { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
        .confirmationDialog(
            "Reset app data?",
            isPresented: $showResetConfirm1,
            titleVisibility: .visible
        ) {
            Button("Continue", role: .destructive) { showResetConfirm2 = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes the on-device store files. This can't be undone.")
        }
        .confirmationDialog(
            "Are you absolutely sure?",
            isPresented: $showResetConfirm2,
            titleVisibility: .visible
        ) {
            Button("Delete everything and reset", role: .destructive) { resetAppData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("There is no way to recover your data after this.")
        }
    }

    // MARK: Actions

    private func exportStoreFiles() {
        let urls = StoreBootstrap.storeFileURLs().filter { FileManager.default.fileExists(atPath: $0.path) }
        guard !urls.isEmpty else {
            exportError = "No store files were found on disk."
            return
        }
        shareURLs = urls
        showShareSheet = true
    }

    private func resetAppData() {
        var didFail = false
        for url in StoreBootstrap.storeFileURLs() {
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                didFail = true
            }
        }
        guard !didFail else {
            exportError = "Couldn't reset all store files. Your draft and reminders were left untouched. Try again or export the files first."
            return
        }

        DataLifecycleManager.clearRecoverablePrivateState()
        NotificationManager.shared.cancelAll()
        onRetry()
    }
}

#Preview {
    StoreRecoveryView(
        error: NSError(domain: "Hindsight", code: 1, userInfo: [NSLocalizedDescriptionKey: "The file couldn't be opened because it is corrupted."]),
        onRetry: {}
    )
}
