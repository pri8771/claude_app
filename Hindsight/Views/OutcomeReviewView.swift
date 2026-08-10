//
//  OutcomeReviewView.swift
//  Hindsight
//
//  Resolves sealed forecasts while keeping the original evidence immutable.
//

import SwiftUI
import SwiftData

private enum OutcomeReviewFocus: Hashable {
    case predictionOutcomes
}

struct OutcomeReviewView: View {
    @Bindable var decision: Decision

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var notificationManager: NotificationManager

    // Resolution state deliberately has no subjective defaults. The persisted
    // model predates optional ratings, so new values are assigned only after a
    // person explicitly chooses them.
    @State private var whatHappened = ""
    @State private var outcomeQuality: Int?
    @State private var decisionQuality: Int?
    @State private var wouldDoAgain: Bool?
    @State private var whatSurprised = ""
    @State private var mainLesson = ""
    @State private var predictionVerdicts: [UUID: PredictionStatus] = [:]
    @State private var predictionResults: [UUID: String] = [:]
    @State private var baselineSnapshot: OutcomeReviewDraftSnapshot?
    @State private var restoredDraft = false
    @State private var hasLoadedDraft = false
    @State private var isSaving = false
    @State private var showDismissConfirmation = false
    @State private var showPredictionValidation = false
    @State private var saveError: String?
    @AccessibilityFocusState private var accessibilityFocus: OutcomeReviewFocus?

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                        intro
                        predictionsSection
                        whatHappenedSection
                        ratingsSection
                        reflectionSection
                        HButton(title: isSaving ? "Saving…" : "Save review", icon: "checkmark") { save() }
                            .disabled(isSaving)
                            .padding(.top, HindsightTheme.Spacing.sm)
                        Color.clear.frame(height: 12)
                    }
                    .padding(HindsightTheme.Spacing.md)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Review outcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { requestDismissal() }
                        .tint(HindsightTheme.Colors.textSecondary)
                }
            }
            .onAppear(perform: seedExistingReviewAndDraft)
            .onChange(of: whatHappened) { _, _ in persistDraftIfNeeded() }
            .onChange(of: outcomeQuality) { _, _ in persistDraftIfNeeded() }
            .onChange(of: decisionQuality) { _, _ in persistDraftIfNeeded() }
            .onChange(of: wouldDoAgain) { _, _ in persistDraftIfNeeded() }
            .onChange(of: whatSurprised) { _, _ in persistDraftIfNeeded() }
            .onChange(of: mainLesson) { _, _ in persistDraftIfNeeded() }
            .onChange(of: predictionVerdicts) { _, _ in persistDraftIfNeeded() }
            .onChange(of: predictionResults) { _, _ in persistDraftIfNeeded() }
            .confirmationDialog("Keep this draft?", isPresented: $showDismissConfirmation, titleVisibility: .visible) {
                Button("Keep Draft") {
                    persistDraftIfNeeded(force: true)
                    dismiss()
                }
                Button("Discard", role: .destructive) {
                    OutcomeReviewDraftStore.clear(for: decision.id)
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your review has not been saved yet. You can keep it for later or discard it.")
            }
            .alert("Couldn't save", isPresented: Binding(
                get: { saveError != nil }, set: { if !$0 { saveError = nil } }
            )) {
                Button("Try Again") { save() }
                Button("Keep Editing", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "Your review is still here. Please try again.")
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges || isSaving)
    }

    // MARK: Evidence and form sections

    private var intro: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HStack {
                Text("ORIGINAL FORECAST · LOCKED")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(0.6)
                    .foregroundStyle(HindsightTheme.Colors.accent)
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .accessibilityHidden(true)
            }
            Text(decision.title)
                .font(HindsightTheme.Typography.authoredStatement)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: HindsightTheme.Spacing.sm) { evidenceDates }
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) { evidenceDates }
            }
            if !decision.notes.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ORIGINAL WHY · LOCKED")
                        .font(HindsightTheme.Typography.metadata)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    Text(decision.notes)
                        .font(HindsightTheme.Typography.callout)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
            if SampleData.isDemoDecision(decision) {
                Text("EXAMPLE RECORD · EXCLUDED FROM PERSONAL INSIGHTS")
                    .font(HindsightTheme.Typography.metadata)
                    .foregroundStyle(HindsightTheme.Colors.accent)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Original forecast, locked. \(decision.title). Created \(decision.createdAt.formatted(date: .long, time: .omitted)). Review date \(decision.dueDate.formatted(date: .long, time: .omitted)).")
    }

    @ViewBuilder private var predictionsSection: some View {
        if !decision.predictions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(
                    title: "Resolve each forecast",
                    subtitle: "Choose what happened for every pending forecast before saving.",
                    systemImage: "scope"
                )
                if showPredictionValidation {
                    Label("Choose an outcome for every pending forecast before saving.",
                          systemImage: "exclamationmark.circle.fill")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.amber)
                        .accessibilityFocused($accessibilityFocus, equals: .predictionOutcomes)
                }
                ForEach(decision.sortedPredictions) { prediction in
                    PredictionVerdictRow(
                        prediction: prediction,
                        verdict: Binding(
                            get: { predictionVerdicts[prediction.id] },
                            set: { verdict in
                                if let verdict {
                                    predictionVerdicts[prediction.id] = verdict
                                } else {
                                    predictionVerdicts.removeValue(forKey: prediction.id)
                                }
                            }
                        ),
                        result: Binding(
                            get: { predictionResults[prediction.id] ?? "" },
                            set: { predictionResults[prediction.id] = $0 }
                        )
                    )
                }
            }
        }
    }

    private var whatHappenedSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "What happened overall?", subtitle: "Optional context for your future self", systemImage: "text.bubble.fill")
            HTextEditor(text: $whatHappened, placeholder: "Describe how it turned out…",
                        accessibilityIdentifier: "outcomeReview.whatHappened",
                        accessibilityLabel: "What happened overall",
                        accessibilityHint: "Optional context for your future self")
        }
    }

    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            OptionalRatingCard(
                title: "How was the result?",
                detail: "Optional. A result and a good process are not the same thing.",
                rating: $outcomeQuality,
                tint: HindsightTheme.Colors.success,
                allowsClearing: true
            )
            OptionalRatingCard(
                title: "How was your decision-making?",
                detail: "Optional. Judge the process separately from luck.",
                rating: $decisionQuality,
                tint: HindsightTheme.Colors.amber,
                allowsClearing: true
            )
            WouldRepeatCard(selection: $wouldDoAgain, allowsClearing: true)
        }
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "What surprised you?", subtitle: "Optional", systemImage: "sparkle.magnifyingglass")
                HTextEditor(text: $whatSurprised, placeholder: "Anything you didn't see coming…", minHeight: 80)
            }
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Main lesson learned", subtitle: "Optional", systemImage: "lightbulb.fill")
                HTextEditor(text: $mainLesson, placeholder: "The one thing to remember next time…", minHeight: 80)
            }
        }
    }

    // MARK: Draft recovery

    private var currentSnapshot: OutcomeReviewDraftSnapshot {
        let predictions = decision.predictions.compactMap { prediction -> OutcomeReviewPredictionDraft? in
            let verdict = predictionVerdicts[prediction.id]
            let result = predictionResults[prediction.id] ?? ""
            guard verdict != nil || !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return OutcomeReviewPredictionDraft(predictionID: prediction.id, verdict: verdict, result: result)
        }
        .sorted { $0.predictionID.uuidString < $1.predictionID.uuidString }

        return OutcomeReviewDraftSnapshot(
            decisionID: decision.id,
            whatHappened: whatHappened,
            outcomeQuality: outcomeQuality,
            decisionQuality: decisionQuality,
            wouldDoAgain: wouldDoAgain,
            whatSurprised: whatSurprised,
            mainLesson: mainLesson,
            predictions: predictions
        )
    }

    private var hasUnsavedChanges: Bool {
        guard hasLoadedDraft else { return false }
        return restoredDraft || (currentSnapshot.hasContent && currentSnapshot != baselineSnapshot)
    }

    private func seedExistingReviewAndDraft() {
        guard !hasLoadedDraft else { return }

        if let review = decision.outcomeReview {
            whatHappened = review.whatHappened
            outcomeQuality = review.hasOutcomeQuality ? review.outcomeQuality : nil
            decisionQuality = review.hasDecisionQuality ? review.decisionQuality : nil
            wouldDoAgain = review.hasWouldDoAgain ? review.wouldDoAgain : nil
            whatSurprised = review.whatSurprised
            mainLesson = review.mainLesson
        }
        for prediction in decision.predictions {
            if prediction.status != .pending {
                predictionVerdicts[prediction.id] = prediction.status
            }
            predictionResults[prediction.id] = prediction.actualResult ?? ""
        }

        baselineSnapshot = currentSnapshot
        if let draft = OutcomeReviewDraftStore.load(for: decision.id) {
            apply(draft)
            restoredDraft = draft.hasContent
        }
        hasLoadedDraft = true
    }

    private func apply(_ snapshot: OutcomeReviewDraftSnapshot) {
        whatHappened = snapshot.whatHappened
        outcomeQuality = snapshot.outcomeQuality
        decisionQuality = snapshot.decisionQuality
        wouldDoAgain = snapshot.wouldDoAgain
        whatSurprised = snapshot.whatSurprised
        mainLesson = snapshot.mainLesson
        for prediction in snapshot.predictions {
            if let verdict = prediction.verdict {
                predictionVerdicts[prediction.predictionID] = verdict
            }
            predictionResults[prediction.predictionID] = prediction.result
        }
    }

    private func persistDraftIfNeeded(force: Bool = false) {
        guard hasLoadedDraft else { return }
        let snapshot = currentSnapshot
        if force || restoredDraft || snapshot != baselineSnapshot {
            OutcomeReviewDraftStore.save(snapshot)
        }
    }

    private func requestDismissal() {
        if hasUnsavedChanges {
            showDismissConfirmation = true
        } else {
            dismiss()
        }
    }

    // MARK: Persistence

    private var pendingPredictionsWithoutTerminalOutcome: [Prediction] {
        decision.predictions.filter {
            guard $0.status == .pending else { return false }
            guard let verdict = predictionVerdicts[$0.id] else { return true }
            return verdict == .pending
        }
    }

    private var hasReviewContent: Bool {
        !whatHappened.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        outcomeQuality != nil ||
        decisionQuality != nil ||
        wouldDoAgain != nil ||
        !whatSurprised.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !mainLesson.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard !isSaving else { return }
        guard pendingPredictionsWithoutTerminalOutcome.isEmpty else {
            if reduceMotion { showPredictionValidation = true }
            else { withAnimation { showPredictionValidation = true } }
            accessibilityFocus = .predictionOutcomes
            HapticsManager.shared.validationWarning()
            return
        }

        isSaving = true
        defer { isSaving = false }

        let input = OutcomeReviewPersistenceService.Input(
            whatHappened: whatHappened,
            outcomeQuality: outcomeQuality,
            decisionQuality: decisionQuality,
            wouldDoAgain: wouldDoAgain,
            whatSurprised: whatSurprised,
            mainLesson: mainLesson,
            predictionVerdicts: predictionVerdicts,
            predictionResults: predictionResults,
            createsReview: hasReviewContent
        )

        guard OutcomeReviewPersistenceService.save(input, for: decision, in: context) else {
            persistDraftIfNeeded(force: true)
            saveError = "Your review wasn't saved. It is still here to retry."
            return
        }

        OutcomeReviewDraftStore.clear(for: decision.id)
        for prediction in decision.predictions where prediction.status != .pending {
            notificationManager.cancelReminder(for: prediction)
        }
        notificationManager.cancelDecisionReminderOnly(for: decision)
        notificationManager.schedulePendingPredictionReminders(for: decision)
        HapticsManager.shared.outcomeReviewed()
        dismiss()
    }

    @ViewBuilder private var evidenceDates: some View {
        HBadge(text: "Created \(decision.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))",
               icon: "calendar.badge.clock", color: HindsightTheme.Colors.textSecondary)
        HBadge(text: "Review \(decision.dueDate.formatted(.dateTime.month(.abbreviated).day().year()))",
               icon: "calendar", color: HindsightTheme.Colors.steel)
    }
}

// MARK: - Optional subjective reflection controls

private struct OptionalRatingCard: View {
    let title: String
    let detail: String
    @Binding var rating: Int?
    let tint: Color
    let allowsClearing: Bool

    var body: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                Text(title)
                    .font(HindsightTheme.Typography.headline)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(detail)
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            rating = value
                            HapticsManager.shared.selectionChanged()
                        } label: {
                            Text("\(value)")
                                .font(HindsightTheme.Typography.callout)
                                .monospacedDigit()
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(rating == value ? tint : tint.opacity(0.14))
                                .foregroundStyle(rating == value ? HindsightTheme.Colors.surface : tint)
                                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(value) out of 5")
                        .accessibilityValue(rating == value ? "Selected" : "Not selected")
                    }
                }
                if rating == nil {
                    Text("Not rated")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                } else if allowsClearing {
                    Button("Clear rating") { rating = nil }
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .frame(minHeight: 44)
                }
            }
        }
    }
}

private struct WouldRepeatCard: View {
    @Binding var selection: Bool?
    let allowsClearing: Bool

    var body: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                Text("Would you make the same decision again?")
                    .font(HindsightTheme.Typography.headline)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text("Optional — knowing what you know now.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                HStack(spacing: HindsightTheme.Spacing.sm) {
                    repeatButton(title: "Yes", value: true)
                    repeatButton(title: "No", value: false)
                }
                if selection == nil {
                    Text("No answer recorded")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                } else if allowsClearing {
                    Button("Clear answer") { selection = nil }
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .frame(minHeight: 44)
                }
            }
        }
    }

    private func repeatButton(title: String, value: Bool) -> some View {
        Button {
            selection = value
            HapticsManager.shared.selectionChanged()
        } label: {
            Text(title)
                .font(HindsightTheme.Typography.callout)
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(selection == value ? HindsightTheme.Colors.surface : HindsightTheme.Colors.steel)
                .background(selection == value ? HindsightTheme.Colors.steel : HindsightTheme.Colors.steel.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityValue(selection == value ? "Selected" : "Not selected")
    }
}

// MARK: - Prediction outcome row

private struct PredictionVerdictRow: View {
    let prediction: Prediction
    @Binding var verdict: PredictionStatus?
    @Binding var result: String

    private let options: [PredictionStatus] = [.correct, .incorrect, .partial]

    var body: some View {
        HCard(background: HindsightTheme.Colors.cardElevated) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HStack(spacing: 6) {
                    Text("\(prediction.probabilityPercent)%")
                        .font(HindsightTheme.Typography.caption2)
                        .foregroundStyle(HindsightTheme.Colors.amber)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(HindsightTheme.Colors.amber.opacity(0.15))
                        .clipShape(Capsule())
                    Text(prediction.title)
                        .font(HindsightTheme.Typography.callout)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("Original forecast · locked")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)

                VStack(spacing: 6) {
                    ForEach(options) { status in
                        Button {
                            verdict = status
                            HapticsManager.shared.selectionChanged()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: status.icon).font(.system(size: 11, weight: .bold))
                                Text(status.eventOutcomeLabel).font(HindsightTheme.Typography.subheadline)
                                Spacer()
                                if verdict == status {
                                    Text("Selected")
                                        .font(HindsightTheme.Typography.caption)
                                }
                            }
                            .foregroundStyle(verdict == status ? HindsightTheme.Colors.surface : status.color)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, HindsightTheme.Spacing.md)
                            .frame(minHeight: 44)
                            .background(verdict == status ? status.color : status.color.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(status.eventOutcomeLabel)
                        .accessibilityValue(verdict == status ? "Selected" : "Not selected")
                    }
                }

                HTextField(text: $result,
                           placeholder: "What made this outcome clear? (optional)",
                           accessibilityLabel: "Optional outcome detail")
            }
        }
    }
}

#Preview {
    OutcomeReviewView(decision: try! SampleData.previewContainer.mainContext.fetch(FetchDescriptor<Decision>()).first!)
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
