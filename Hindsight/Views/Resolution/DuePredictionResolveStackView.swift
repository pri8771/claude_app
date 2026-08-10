//
//  DuePredictionResolveStackView.swift
//  Hindsight
//
//  A focused, low-friction ritual for resolving each due prediction.
//

import SwiftUI
import SwiftData

enum PredictionResolutionDraftStore {
    private static func drafts(defaults: UserDefaults) -> [String: String] {
        guard let data = defaults.data(forKey: AppStorageKeys.predictionResolutionDrafts) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }

    static func load(for predictionID: UUID, defaults: UserDefaults = .standard) -> String {
        drafts(defaults: defaults)[predictionID.uuidString] ?? ""
    }

    static func save(_ note: String, for predictionID: UUID, defaults: UserDefaults = .standard) {
        var values = drafts(defaults: defaults)
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            values.removeValue(forKey: predictionID.uuidString)
        } else {
            values[predictionID.uuidString] = note
        }
        if values.isEmpty {
            defaults.removeObject(forKey: AppStorageKeys.predictionResolutionDrafts)
        } else if let data = try? JSONEncoder().encode(values) {
            defaults.set(data, forKey: AppStorageKeys.predictionResolutionDrafts)
        }
    }

    static func clear(for predictionID: UUID, defaults: UserDefaults = .standard) {
        save("", for: predictionID, defaults: defaults)
    }

    static func clearAll(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: AppStorageKeys.predictionResolutionDrafts)
    }
}

struct DuePredictionResolveStackView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \Prediction.dueDate) private var predictions: [Prediction]

    @State private var note = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var lastAttemptedStatus: PredictionStatus = .partial
    @State private var showNote = false
    @State private var showDismissDraftConfirmation = false

    private var duePredictions: [Prediction] {
        predictions.filter {
            $0.status == .pending &&
            $0.dueDate <= Date() &&
            ($0.decision.map { !SampleData.isDemoDecision($0) } ?? true)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()
                if let prediction = duePredictions.first {
                    resolveCard(for: prediction)
                        .id(prediction.id)
                        .transition(reduceMotion ? .identity : .opacity.combined(with: .move(edge: .trailing)))
                } else {
                    emptyState
                }
            }
            .animation(reduceMotion ? nil : .easeInOut, value: duePredictions.first?.id)
            .navigationTitle("Resolve")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        if hasOutcomeContextDraft {
                            showDismissDraftConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                        .tint(HindsightTheme.Colors.textSecondary)
                }
            }
            .alert("Couldn't save", isPresented: Binding(
                get: { saveError != nil }, set: { if !$0 { saveError = nil } }
            )) {
                Button("Try Again") { resolveCurrent(as: lastAttemptedStatus) }
                Button("Keep Editing", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "Your result is still here. Try again when you're ready.")
            }
            .confirmationDialog("Keep outcome context for later?", isPresented: $showDismissDraftConfirmation, titleVisibility: .visible) {
                Button("Keep Draft") { dismiss() }
                Button("Discard Context", role: .destructive) {
                    if let prediction = duePredictions.first {
                        PredictionResolutionDraftStore.clear(for: prediction.id)
                    }
                    note = ""
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your outcome context is saved on this device until you resolve this forecast or discard it.")
            }
        }
        .interactiveDismissDisabled(hasOutcomeContextDraft || isSaving)
    }

    private func resolveCard(for prediction: Prediction) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                HCard(background: HindsightTheme.Colors.cardElevated) {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                        Text("Due for a look back")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        if let title = prediction.decision?.title,
                           !title.isEmpty,
                           title != prediction.title {
                            Text(title)
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        }
                        Text(prediction.title)
                            .font(HindsightTheme.Typography.title2)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 8) {
                            HBadge(text: "\(prediction.probabilityPercent)% confidence", icon: "gauge.medium", color: HindsightTheme.Colors.amber)
                            HBadge(text: prediction.dueDate.formatted(.dateTime.month(.abbreviated).day()), icon: "calendar", color: HindsightTheme.Colors.textSecondary)
                        }
                        if let decision = prediction.decision, !decision.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ORIGINAL WHY")
                                    .font(HindsightTheme.Typography.metadata)
                                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                                Text(decision.notes)
                                    .font(HindsightTheme.Typography.callout)
                                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            }
                        }
                        if let decision = prediction.decision, SampleData.isDemoDecision(decision) {
                            Text("EXAMPLE RECORD · EXCLUDED FROM PERSONAL INSIGHTS")
                                .font(HindsightTheme.Typography.metadata)
                                .foregroundStyle(HindsightTheme.Colors.accent)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Button {
                        if reduceMotion { showNote.toggle() }
                        else { withAnimation(.easeInOut(duration: 0.2)) { showNote.toggle() } }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add outcome context")
                                    .font(HindsightTheme.Typography.headline)
                                Text("Optional; add it before choosing an outcome")
                                    .font(HindsightTheme.Typography.footnote)
                                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: showNote ? "chevron.up" : "plus")
                                .foregroundStyle(HindsightTheme.Colors.steel)
                        }
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(showNote ? "Hide optional outcome context" : "Add optional outcome context")
                    if showNote {
                        HTextEditor(text: noteBinding(for: prediction), placeholder: "What made the outcome clear?", minHeight: 100,
                                    accessibilityIdentifier: "resolvePrediction.note",
                                    accessibilityLabel: "Optional outcome context")
                    }
                }
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    HSectionHeader(title: "Did it happen?", subtitle: "Nothing is selected for you", systemImage: "scope")
                    verdictButton("It happened", status: .correct, for: prediction)
                    verdictButton("It did not happen", status: .incorrect, for: prediction)
                    verdictButton("It cannot be judged clearly", status: .partial, for: prediction)
                }
                Text("This saves the result and moves to the next due prediction.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(HindsightTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            note = PredictionResolutionDraftStore.load(for: prediction.id)
            showNote = !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func verdictButton(_ title: String, status: PredictionStatus, for prediction: Prediction) -> some View {
        Button {
            resolve(prediction, as: status)
        } label: {
            HStack {
                Image(systemName: status.icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .font(HindsightTheme.Typography.headline)
            .foregroundStyle(status.color)
            .padding()
            .frame(maxWidth: .infinity)
            .background(status.color.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .accessibilityLabel(title)
        .accessibilityHint("Saves this result and shows the next due prediction")
    }

    private var emptyState: some View {
        VStack(spacing: HindsightTheme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(HindsightTheme.Colors.success)
            Text("Nothing due right now")
                .font(HindsightTheme.Typography.title2)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text("You can come back when another prediction is ready to revisit.")
                .font(HindsightTheme.Typography.body)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            HButton(title: "Done", icon: "checkmark") { dismiss() }
                .padding(.top, HindsightTheme.Spacing.sm)
        }
        .padding(HindsightTheme.Spacing.xl)
    }

    private func resolve(_ prediction: Prediction, as status: PredictionStatus) {
        guard !isSaving else { return }
        lastAttemptedStatus = status
        isSaving = true
        defer { isSaving = false }

        switch PredictionResolutionService.resolve(prediction, as: status, note: note, in: context) {
        case .saved:
            PredictionResolutionDraftStore.clear(for: prediction.id)
            notificationManager.cancelReminder(for: prediction)
            HapticsManager.shared.selectionChanged()
            note = ""
            showNote = false
        case .alreadyResolved:
            break
        case .failed:
            saveError = "Your result wasn't saved. The card and note are still ready to retry."
        }
    }

    private func resolveCurrent(as status: PredictionStatus) {
        guard let prediction = duePredictions.first else { return }
        resolve(prediction, as: status)
    }

    private var hasOutcomeContextDraft: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func noteBinding(for prediction: Prediction) -> Binding<String> {
        Binding(
            get: { note },
            set: { newValue in
                note = newValue
                PredictionResolutionDraftStore.save(newValue, for: prediction.id)
            }
        )
    }
}

#Preview {
    DuePredictionResolveStackView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
