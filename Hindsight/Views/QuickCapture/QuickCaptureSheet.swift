//
//  QuickCaptureSheet.swift
//  Hindsight
//
//  A single-screen, low-friction way to record one prediction for later review.
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class QuickCaptureDraft {
    var statement = ""
    var confidence: Int?
    var selectedHorizon: QuickCaptureHorizon?
    var customDate = QuickCaptureHorizon.tomorrow.date(from: Date(), calendar: .current)

    var trimmedStatement: String {
        statement.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isStatementValid: Bool { !trimmedStatement.isEmpty }

    func dueDate(now: Date = Date(), calendar: Calendar = .current) -> Date? {
        switch selectedHorizon {
        case .custom: return customDate > calendar.startOfDay(for: now) ? customDate : nil
        case let horizon?: return horizon.date(from: now, calendar: calendar)
        case nil: return nil
        }
    }

    /// Quick captures intentionally use visible, low-commitment defaults: Personal, low stakes,
    /// and reversible. The prediction statement is also the decision title so it remains useful
    /// in the existing Today and detail surfaces without adding fields to the persisted schema.
    func makeDecision(now: Date = Date(), calendar: Calendar = .current) -> Decision? {
        guard
            let confidence,
            let dueDate = dueDate(now: now, calendar: calendar),
            isStatementValid
        else { return nil }
        let score = ClarityScore.score(title: trimmedStatement, notes: "", optionCount: 0,
                                       optionsWithTradeoffs: 0, predictionCount: 1, hasReviewDate: true)
        let decision = Decision(title: trimmedStatement, notes: "", category: .personal,
                                stakesLevel: .low, status: .awaitingReview, isReversible: true,
                                clarityScore: score, createdAt: now, decidedAt: now, dueDate: dueDate)
        decision.predictions = [Prediction(title: trimmedStatement, probabilityPercent: confidence,
                                            dueDate: dueDate, status: .pending)]
        return decision
    }
}

enum QuickCaptureHorizon: String, CaseIterable, Identifiable {
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case sixMonths = "Six Months"
    case custom = "Custom"

    var id: String { rawValue }

    func date(from now: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: now)
        switch self {
        case .tomorrow:
            return calendar.date(byAdding: .day, value: 1, to: start) ?? start
        case .thisWeek:
            let finalWeekday = ((calendar.firstWeekday + 5) % 7) + 1
            let daysUntilWeekEnd = (finalWeekday - calendar.component(.weekday, from: start) + 7) % 7
            let days = max(1, daysUntilWeekEnd)
            return calendar.date(byAdding: .day, value: days, to: start) ?? start
        case .thisMonth:
            guard let interval = calendar.dateInterval(of: .month, for: start) else { return start }
            let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
            return lastDay > start ? lastDay : (calendar.date(byAdding: .day, value: 1, to: start) ?? start)
        case .sixMonths:
            return calendar.date(byAdding: .month, value: 6, to: start) ?? start
        case .custom:
            return start
        }
    }
}

struct QuickCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var notificationManager: NotificationManager
    @AppStorage(AppStorageKeys.didCompleteQuickCaptureNudge) private var didCompleteNudge = false

    @State private var draft = QuickCaptureDraft()
    @State private var saveError: String?
    @State private var isSaving = false
    @FocusState private var isStatementFocused: Bool
    private let confidenceOptions = [55, 65, 75, 85, 95]

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                        if !didCompleteNudge { shortHorizonNudge }
                        statementSection
                        confidenceSection
                        reviewDateSection
                        HCard {
                            Text(ClarityScore.invitation)
                                .font(HindsightTheme.Typography.footnote)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                    }
                    .padding(HindsightTheme.Spacing.md)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Quick Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave || isSaving)
                        .accessibilityHint(canSave ? "Saves one prediction for later review" : validationMessage)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isStatementFocused = false }
                        .accessibilityIdentifier("quickCapture.keyboardDone")
                }
            }
            .safeAreaInset(edge: .bottom) {
                HButton(title: isSaving ? "Saving…" : "Save Prediction", icon: "checkmark.seal.fill",
                        isEnabled: canSave && !isSaving, action: save)
                    .padding(.horizontal, HindsightTheme.Spacing.md)
                    .padding(.vertical, HindsightTheme.Spacing.sm)
                    .background(.ultraThinMaterial)
            }
            .alert("Couldn't save prediction", isPresented: Binding(
                get: { saveError != nil }, set: { if !$0 { saveError = nil } }
            )) {
                Button("Try Again") { save() }
                Button("Keep Editing", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "Your capture is still here. Please try again.")
            }
        }
        .onAppear { isStatementFocused = true }
    }

    private var shortHorizonNudge: some View {
        HCard {
            HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(HindsightTheme.Colors.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("A quick check-in makes this useful")
                        .font(HindsightTheme.Typography.headline)
                    Text("Try a near review date so future you can see what happened.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
                Spacer(minLength: 0)
                Button("Dismiss") { didCompleteNudge = true }
                    .font(HindsightTheme.Typography.caption)
            }
            .accessibilityElement(children: .contain)
        }
    }

    private var statementSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            Text("What do you predict?")
                .font(HindsightTheme.Typography.title2)
            TextField("For example, I’ll enjoy this job in six months", text: $draft.statement, axis: .vertical)
                .lineLimit(3...6)
                .textInputAutocapitalization(.sentences)
                .focused($isStatementFocused)
                .padding(HindsightTheme.Spacing.md)
                .background(HindsightTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
                .accessibilityIdentifier("Quick capture statement")
            if !draft.statement.isEmpty && !draft.isStatementValid {
                Text("Enter a prediction before saving.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.accent)
                    .accessibilityLabel("A prediction is required before saving")
            }
        }
    }

    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HStack {
                Text("How confident are you?").font(HindsightTheme.Typography.title2)
                Spacer()
                if let confidence = draft.confidence {
                    Text("\(confidence)%")
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .monospacedDigit()
                }
            }
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 72), spacing: HindsightTheme.Spacing.xs)],
                spacing: HindsightTheme.Spacing.xs
            ) {
                ForEach(confidenceOptions, id: \.self) { confidence in
                    Button {
                        draft.confidence = confidence
                        HapticsManager.shared.selectionChanged()
                    } label: {
                        Text("\(confidence)%")
                            .font(HindsightTheme.Typography.subheadline)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                draft.confidence == confidence
                                    ? HindsightTheme.Colors.accent
                                    : HindsightTheme.Colors.card
                            )
                            .foregroundStyle(
                                draft.confidence == confidence
                                    ? Color.white
                                    : HindsightTheme.Colors.textPrimary
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(confidence) percent confidence")
                    .accessibilityValue(draft.confidence == confidence ? "Selected" : "Not selected")
                    .accessibilityIdentifier("quickCapture.confidence.\(confidence)")
                }
            }
            Text("Choose the closest fit. There is no assumed answer.")
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
    }

    private var reviewDateSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            Text("Ask me again when")
                .font(HindsightTheme.Typography.title2)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HindsightTheme.Spacing.sm)], spacing: HindsightTheme.Spacing.sm) {
                ForEach(QuickCaptureHorizon.allCases) { horizon in
                    Button {
                        draft.selectedHorizon = horizon
                        HapticsManager.shared.selectionChanged()
                    } label: {
                        Text(horizon.rawValue)
                            .font(HindsightTheme.Typography.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(draft.selectedHorizon == horizon ? HindsightTheme.Colors.accent : HindsightTheme.Colors.card)
                            .foregroundStyle(draft.selectedHorizon == horizon ? Color.white : HindsightTheme.Colors.textPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(horizon.rawValue)
                    .accessibilityValue(draft.selectedHorizon == horizon ? "Selected" : "Not selected")
                }
            }
            if draft.selectedHorizon == .custom {
                let earliestDate = Calendar.current.date(byAdding: .day, value: 1,
                                                         to: Calendar.current.startOfDay(for: Date())) ?? Date()
                DatePicker("Review date", selection: $draft.customDate,
                           in: earliestDate...,
                           displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            if let dueDate = draft.dueDate() {
                Text("Review on \(dueDate.formatted(date: .long, time: .omitted)).")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .accessibilityLabel("Selected review date: \(dueDate.formatted(date: .long, time: .omitted))")
            } else {
                Text("Choose a future review date.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
    }

    private var canSave: Bool {
        draft.isStatementValid && draft.confidence != nil && draft.dueDate() != nil
    }

    private var validationMessage: String {
        if !draft.isStatementValid { return "Enter a prediction before saving" }
        if draft.confidence == nil { return "Choose your confidence before saving" }
        return "Choose a future review date before saving"
    }

    private func save() {
        guard !isSaving, let decision = draft.makeDecision() else { return }
        isSaving = true
        context.insert(decision)
        if PersistenceService.saveOrReport(context) {
            didCompleteNudge = true
            Task { await notificationManager.scheduleReviewReminderIfAllowed(for: decision) }
            HapticsManager.shared.decisionSealed()
            dismiss()
        } else {
            // Keep the user-owned draft, but remove the unsaved graph so a retry cannot duplicate it.
            context.delete(decision)
            isSaving = false
            saveError = "Your capture is still here. Please try again."
        }
    }
}

#Preview {
    QuickCaptureSheet()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
