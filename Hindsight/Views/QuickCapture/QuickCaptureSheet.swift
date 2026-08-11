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
    var reasoning = ""
    var confidence: Int?
    var selectedHorizon: QuickCaptureHorizon?
    var customDate = QuickCaptureHorizon.tomorrow.date(from: Date(), calendar: .current)

    init(snapshot: QuickCaptureDraftSnapshot? = nil) {
        guard let snapshot else { return }
        statement = snapshot.statement
        reasoning = snapshot.reasoning
        confidence = snapshot.confidence
        selectedHorizon = snapshot.horizon.flatMap(QuickCaptureHorizon.init(rawValue:))
        customDate = snapshot.customDate
    }

    var trimmedStatement: String {
        statement.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isStatementValid: Bool { !trimmedStatement.isEmpty }

    var trimmedReasoning: String {
        reasoning.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasContent: Bool {
        !trimmedStatement.isEmpty || !trimmedReasoning.isEmpty || confidence != nil || selectedHorizon != nil
    }

    var snapshot: QuickCaptureDraftSnapshot {
        QuickCaptureDraftSnapshot(
            statement: statement,
            reasoning: reasoning,
            confidence: confidence,
            horizon: selectedHorizon?.rawValue,
            customDate: customDate
        )
    }

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
        let score = ClarityScore.score(title: trimmedStatement, notes: trimmedReasoning, optionCount: 0,
                                       optionsWithTradeoffs: 0, predictionCount: 1, hasReviewDate: true)
        let decision = Decision(title: trimmedStatement, notes: trimmedReasoning, category: .personal,
                                stakesLevel: .low, status: .awaitingReview, isReversible: true,
                                clarityScore: score, createdAt: now, decidedAt: now, dueDate: dueDate)
        decision.predictions = [Prediction(title: trimmedStatement, probabilityPercent: confidence,
                                            dueDate: dueDate, status: .pending)]
        return decision
    }
}

struct QuickCaptureDraftSnapshot: Codable, Equatable {
    let statement: String
    let reasoning: String
    let confidence: Int?
    let horizon: String?
    let customDate: Date
}

enum QuickCaptureDraftStore {
    static func load(defaults: UserDefaults = .standard) -> QuickCaptureDraftSnapshot? {
        guard let data = defaults.data(forKey: AppStorageKeys.quickCaptureDraft) else { return nil }
        return try? JSONDecoder().decode(QuickCaptureDraftSnapshot.self, from: data)
    }

    static func save(_ snapshot: QuickCaptureDraftSnapshot, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: AppStorageKeys.quickCaptureDraft)
    }

    static func clear(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: AppStorageKeys.quickCaptureDraft)
    }
}

enum QuickCaptureHorizon: String, CaseIterable, Identifiable {
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case sixMonths = "Six Months"
    case custom = "Custom"

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .tomorrow: return "Tomorrow"
        case .thisWeek: return "This week"
        case .thisMonth: return "This month"
        case .sixMonths: return "6 months"
        case .custom: return "Pick date"
        }
    }

    var icon: String {
        switch self {
        case .tomorrow: return "sunrise.fill"
        case .thisWeek: return "calendar.badge.clock"
        case .thisMonth: return "calendar"
        case .sixMonths: return "leaf.fill"
        case .custom: return "calendar.badge.plus"
        }
    }

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

private enum QuickCaptureFocus: Hashable {
    case statement
    case reasoning
}

struct QuickCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var notificationManager: NotificationManager
    @AppStorage(AppStorageKeys.didCompleteQuickCaptureNudge) private var didCompleteNudge = false

    @State private var draft = QuickCaptureDraft(snapshot: QuickCaptureDraftStore.load())
    @State private var saveError: String?
    @State private var isSaving = false
    @State private var showDiscardConfirmation = false
    @State private var showReasoning = false
    @FocusState private var focusedField: QuickCaptureFocus?

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                        captureHeader
                        if !didCompleteNudge { shortHorizonNudge }
                        statementSection
                        confidenceSection
                        reviewDateSection
                        reasoningSection
                        lockPromise
                    }
                    .padding(.horizontal, HindsightTheme.Spacing.md)
                    .padding(.top, HindsightTheme.Spacing.sm)
                    .padding(.bottom, HindsightTheme.Spacing.xl)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .hindsightReadableWidth()
                }
                .scrollDismissesKeyboard(.interactively)
                .accessibilityIdentifier("quickCapture.scroll")
            }
            .navigationTitle("New forecast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { cancel() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .accessibilityIdentifier("quickCapture.keyboardDone")
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: save) {
                    HStack(spacing: HindsightTheme.Spacing.sm) {
                        Image(systemName: isSaving ? "hourglass" : "sparkles")
                        Text(isSaving ? "Saving…" : "Lock in my belief")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .padding(.horizontal, HindsightTheme.Spacing.lg)
                        .background {
                            if canSave && !isSaving {
                                HindsightTheme.Colors.accentGradient
                            } else {
                                LinearGradient(
                                    colors: [HindsightTheme.Colors.textTertiary, HindsightTheme.Colors.textTertiary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.pill, style: .continuous))
                        .hindsightShadow(canSave && !isSaving ? HindsightTheme.Shadows.glow : HindsightTheme.Shadows.card)
                }
                .buttonStyle(.plain)
                .disabled(!canSave || isSaving)
                .accessibilityIdentifier("Save Prediction")
                .accessibilityLabel(isSaving ? "Saving forecast" : "Lock forecast")
                .accessibilityValue(canSave ? "Ready" : validationMessage)
                .accessibilityHint(canSave ? "Saves this forecast for later comparison" : validationMessage)
                .padding(.horizontal, HindsightTheme.Spacing.md)
                .padding(.vertical, HindsightTheme.Spacing.sm)
                .background(.ultraThinMaterial)
            }
            .alert("Couldn't save forecast", isPresented: Binding(
                get: { saveError != nil }, set: { if !$0 { saveError = nil } }
            )) {
                Button("Try Again") { save() }
                Button("Keep Editing", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "Your capture is still here. Please try again.")
            }
            .confirmationDialog("Keep this draft?", isPresented: $showDiscardConfirmation, titleVisibility: .visible) {
                Button("Keep Draft") {
                    persistDraft()
                    dismiss()
                }
                Button("Discard", role: .destructive) {
                    QuickCaptureDraftStore.clear()
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your forecast is not saved yet. You can keep it for later or discard it.")
            }
        }
        .futurePostcardScreen()
        .interactiveDismissDisabled(draft.hasContent || isSaving)
        .onAppear {
            showReasoning = !draft.trimmedReasoning.isEmpty
            focusedField = .statement
        }
        .onChange(of: draft.statement) { _, _ in persistDraft() }
        .onChange(of: draft.reasoning) { _, _ in persistDraft() }
        .onChange(of: draft.confidence) { _, _ in persistDraft() }
        .onChange(of: draft.selectedHorizon) { _, _ in persistDraft() }
        .onChange(of: draft.customDate) { _, _ in persistDraft() }
    }

    private var captureHeader: some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(HindsightTheme.Colors.accentGradient)
                Image(systemName: "lightbulb.max.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)
            .hindsightShadow(HindsightTheme.Shadows.glow)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                Text("CAPTURE A SIGNAL")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(0.8)
                    .foregroundStyle(HindsightTheme.Colors.accent)
                Text("What do you believe?")
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Say it now. Compare it with reality later.")
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var shortHorizonNudge: some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: "bolt.fill")
                .foregroundStyle(HindsightTheme.Colors.amber)
                .accessibilityHidden(true)
            Text("Shorter forecasts teach you faster. Tomorrow or this week is a great first signal.")
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
            Spacer(minLength: HindsightTheme.Spacing.sm)
            Button("Dismiss") { didCompleteNudge = true }
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.accent)
                .frame(minHeight: 44)
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.amber.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .stroke(HindsightTheme.Colors.amber.opacity(0.30), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }

    private var statementSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            signalStep(number: "1", title: "Make it checkable", detail: "One outcome your future self can judge")
            TextField("Write one outcome that can later be checked", text: $draft.statement, axis: .vertical)
                .lineLimit(3...6)
                .textInputAutocapitalization(.sentences)
                .focused($focusedField, equals: .statement)
                .font(HindsightTheme.Typography.authoredStatement)
                .padding(HindsightTheme.Spacing.lg)
                .frame(minHeight: 118, alignment: .topLeading)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .background(HindsightTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous)
                        .stroke(HindsightTheme.Colors.categoryPersonal.opacity(0.34), lineWidth: 1.5)
                }
                .hindsightShadow(HindsightTheme.Shadows.raised)
                .accessibilityIdentifier("Quick capture statement")
            if !draft.statement.isEmpty && !draft.isStatementValid {
                Text("Enter a forecast before saving.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.accent)
                    .accessibilityLabel("A forecast is required before saving")
            }
        }
    }

    private var reasoningSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            Button {
                if reduceMotion {
                    showReasoning.toggle()
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) { showReasoning.toggle() }
                }
                if showReasoning { focusedField = .reasoning }
            } label: {
                HStack(spacing: HindsightTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(HindsightTheme.Colors.categoryEducation.opacity(0.13))
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(HindsightTheme.Colors.categoryEducation)
                    }
                    .frame(width: 40, height: 40)
                    .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add your thinking")
                            .font(HindsightTheme.Typography.headline)
                        Text("Optional — evidence, intuition, or assumptions")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: showReasoning ? "chevron.up" : "plus")
                        .foregroundStyle(HindsightTheme.Colors.steel)
                }
                .padding(HindsightTheme.Spacing.md)
                .frame(minHeight: 56)
                .background(HindsightTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showReasoning ? "Hide optional reasoning" : "Add optional reasoning")

            if showReasoning {
                TextField("What evidence or assumption is behind this?", text: $draft.reasoning, axis: .vertical)
                    .lineLimit(2...5)
                    .textInputAutocapitalization(.sentences)
                    .focused($focusedField, equals: .reasoning)
                    .padding(HindsightTheme.Spacing.md)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .background(HindsightTheme.Colors.card)
                    .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                            .stroke(HindsightTheme.Colors.categoryEducation.opacity(0.28), lineWidth: 1)
                    }
                    .accessibilityIdentifier("Quick capture reasoning")
            }
        }
    }

    private var confidenceSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            signalStep(number: "2", title: "How sure are you?", detail: "Choose anywhere from 0 to 100")
            VStack(spacing: HindsightTheme.Spacing.md) {
                if let confidence = draft.confidence {
                    Text("\(confidence)%")
                        .font(.system(size: 58, weight: .bold, design: .rounded))
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    Text(confidenceDescription(confidence))
                        .font(HindsightTheme.Typography.callout)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                } else {
                    Text("—%")
                        .font(.system(size: 58, weight: .bold, design: .rounded))
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    Text("Move the slider to make an intentional choice")
                        .font(HindsightTheme.Typography.callout)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
                Slider(
                    value: Binding(
                        // The thumb rests at neutral 50% until the user interacts; the model stays
                        // nil, so this is never treated as an inferred confidence selection.
                        get: { Double(draft.confidence ?? 50) },
                        set: { value in
                            let selectedValue = Int(value.rounded())
                            if draft.confidence != selectedValue {
                                draft.confidence = selectedValue
                            }
                        }
                    ),
                    in: 0...100,
                    step: 1,
                    onEditingChanged: { isEditing in
                        // Touching neutral is still an explicit 50% selection.
                        if isEditing, draft.confidence == nil {
                            draft.confidence = 50
                        } else if !isEditing, draft.confidence != nil {
                            HapticsManager.shared.selectionChanged()
                        }
                    }
                )
                .tint(HindsightTheme.Colors.accent)
                .frame(minHeight: 48)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    HindsightTheme.Colors.categoryEducation.opacity(0.24),
                                    HindsightTheme.Colors.success.opacity(0.24),
                                    HindsightTheme.Colors.amber.opacity(0.24),
                                    HindsightTheme.Colors.accent.opacity(0.24)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 10)
                }
                .accessibilityLabel("Confidence")
                .accessibilityValue(draft.confidence.map { "\($0) percent" } ?? "Not selected")
                .accessibilityHint("Adjust from 0 to 100 percent. A confidence is required before saving.")
                .accessibilityIdentifier("quickCapture.confidenceSlider")
                HStack {
                    Text("Not at all")
                    Spacer()
                    Text("Completely")
                }
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .accessibilityHidden(true)
            }
            .padding(HindsightTheme.Spacing.lg)
            .background(HindsightTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous)
                    .stroke(HindsightTheme.Colors.accent.opacity(0.20), lineWidth: 1)
            }
            .hindsightShadow(HindsightTheme.Shadows.raised)
        }
    }

    private var reviewDateSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            signalStep(number: "3", title: "When will you know?", detail: "Pick the first date reality can answer")
            ScrollView(.horizontal) {
                HStack(spacing: HindsightTheme.Spacing.sm) {
                    ForEach(QuickCaptureHorizon.allCases) { horizon in
                        Button {
                            draft.selectedHorizon = horizon
                            HapticsManager.shared.selectionChanged()
                        } label: {
                            VStack(spacing: 5) {
                                Image(systemName: horizon.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(horizon.shortLabel)
                                    .font(HindsightTheme.Typography.subheadline)
                            }
                                .foregroundStyle(draft.selectedHorizon == horizon ? Color.white : HindsightTheme.Colors.textPrimary)
                                .padding(.horizontal, 14)
                                .frame(minWidth: 92, minHeight: 68)
                                .background {
                                    if draft.selectedHorizon == horizon {
                                        HindsightTheme.Colors.accentGradient
                                    } else {
                                        LinearGradient(
                                            colors: [HindsightTheme.Colors.card, HindsightTheme.Colors.card],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                                        .stroke(draft.selectedHorizon == horizon ? HindsightTheme.Colors.accent : HindsightTheme.Colors.border,
                                                lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(horizon.rawValue)
                        .accessibilityValue(draft.selectedHorizon == horizon ? "Selected" : "Not selected")
                        .accessibilityIdentifier("quickCapture.horizon.\(horizon.rawValue)")
                    }
                }
            }
            .scrollIndicators(.hidden)
            if draft.selectedHorizon == .custom {
                let earliestDate = Calendar.current.date(byAdding: .day, value: 1,
                                                         to: Calendar.current.startOfDay(for: Date())) ?? Date()
                DatePicker("Review date", selection: $draft.customDate,
                           in: earliestDate...,
                           displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(HindsightTheme.Spacing.md)
                    .background(HindsightTheme.Colors.card, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
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

    private func signalStep(number: String, title: String, detail: String) -> some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            Text(number)
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(HindsightTheme.Colors.accentGradient, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(HindsightTheme.Typography.title2)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(detail)
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
    }

    private var lockPromise: some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(HindsightTheme.Colors.success)
                .accessibilityHidden(true)
            Text("Once saved, your belief, confidence, and check date stay locked—so future-you sees exactly what you thought today.")
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.success.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your original forecast details cannot be edited after saving")
    }

    private func confidenceDescription(_ confidence: Int) -> String {
        switch confidence {
        case 0...20: return "You consider this very unlikely."
        case 21...40: return "You consider this unlikely."
        case 41...60: return "You see this as close to even odds."
        case 61...80: return "You consider this likely."
        default: return "You consider this very likely."
        }
    }

    private var canSave: Bool {
        draft.isStatementValid && draft.confidence != nil && draft.dueDate() != nil
    }

    private var validationMessage: String {
        if !draft.isStatementValid { return "Enter a forecast before saving" }
        if draft.confidence == nil { return "Choose your confidence before saving" }
        return "Choose a future review date before saving"
    }

    private func save() {
        guard !isSaving, let decision = draft.makeDecision() else { return }
        isSaving = true
        if NewDecisionGraphPersistenceService.save(decision, in: context) {
            QuickCaptureDraftStore.clear()
            didCompleteNudge = true
            Task { await notificationManager.scheduleReviewReminderIfAllowed(for: decision) }
            HapticsManager.shared.decisionSealed()
            dismiss()
        } else {
            // Keep the user-owned draft. The save boundary already removed
            // the transient graph, so retry cannot create a duplicate.
            isSaving = false
            saveError = "Your forecast is still here. Please try again."
        }
    }

    private func persistDraft() {
        if draft.hasContent {
            QuickCaptureDraftStore.save(draft.snapshot)
        } else {
            QuickCaptureDraftStore.clear()
        }
    }

    private func cancel() {
        if draft.hasContent {
            showDiscardConfirmation = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    QuickCaptureSheet()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
