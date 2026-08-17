//
//  DecisionDetailView.swift
//  Hindsight
//
//  Full detail screen for a single decision: header, status timeline,
//  the options weighed, the predictions made, and the outcome review (or
//  a prompt to write one).
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct DecisionDetailView: View {
    @Bindable var decision: Decision

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var showOutcomeReview = false
    @State private var showDuePredictionStack = false
    @State private var showDeleteConfirm = false
    @State private var expandedOptionID: UUID?
    @State private var saveError: String?
    @State private var deleteError: String?
    @State private var outcomeRefreshID = UUID()
    @State private var reviewConfirmationDate: Date?

    var body: some View {
        ZStack {
            HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                    if let reviewConfirmationDate {
                        reviewSavedBanner(reviewConfirmationDate)
                    }
                    header
                    timeline
                    if !decision.notes.isEmpty { notesSection }
                    optionsSection
                    predictionsSection
                    outcomeSection
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, HindsightTheme.Spacing.md)
                .padding(.top, HindsightTheme.Spacing.sm)
                .id(outcomeRefreshID)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Decision")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if decision.status == .active {
                        Button {
                            HapticsManager.shared.optionCommitted()
                            markDecided()
                        } label: { Label("Mark as decided", systemImage: "checkmark.circle") }
                    }
                    if decision.status != .reviewed {
                        Button { showOutcomeReview = true } label: { Label("Write outcome review", systemImage: "square.and.pencil") }
                    }
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Label("Delete decision", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle").tint(HindsightTheme.Colors.textPrimary)
                }
                .accessibilityLabel("More options")
            }
        }
        .sheet(isPresented: $showOutcomeReview, onDismiss: {
            // SwiftData relationship changes saved inside a sheet can arrive
            // before this detail hierarchy is invalidated. Rebuild the visible
            // evidence once so the completed review is announced immediately.
            outcomeRefreshID = UUID()
        }) {
            OutcomeReviewView(decision: decision, onSaved: { reviewedAt in
                reviewConfirmationDate = reviewedAt
                outcomeRefreshID = UUID()
            })
        }
        .sheet(isPresented: $showDuePredictionStack) {
            DuePredictionResolveStackView()
        }
        .confirmationDialog("Delete this decision?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteDecision() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes the decision and its predictions. This can't be undone.")
        }
        .alert("Couldn't save", isPresented: Binding(
            get: { saveError != nil }, set: { if !$0 { saveError = nil } }
        )) {
            Button("Cancel", role: .cancel) { saveError = nil }
        } message: { Text(saveError ?? "An error occurred while saving.") }
        .alert("Couldn't delete", isPresented: Binding(
            get: { deleteError != nil }, set: { if !$0 { deleteError = nil } }
        )) {
            Button("Try Again") { deleteDecision() }
            Button("Keep Decision", role: .cancel) { deleteError = nil }
        } message: {
            Text(deleteError ?? "The decision is still here. Please try again.")
        }
    }

    // MARK: Header

    private func reviewSavedBanner(_ reviewedAt: Date) -> some View {
        HCard(background: HindsightTheme.Colors.success.opacity(0.12)) {
            HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(HindsightTheme.Colors.success)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reviewed \(reviewedAt.formatted(.dateTime.month(.wide).day().year()))")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Your outcome and original forecast are now saved together.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text(decision.title)
                        .font(HindsightTheme.Typography.title)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        HBadge(text: decision.category.rawValue, icon: decision.category.icon,
                               color: decision.category.color)
                        HBadge(text: "\(decision.stakesLevel.rawValue) stakes", icon: decision.stakesLevel.icon,
                               color: decision.stakesLevel.color)
                    }
                    HStack(spacing: 6) {
                        HBadge(text: decision.status.rawValue, icon: decision.status.icon,
                               color: decision.status.color, filled: true)
                        HBadge(text: decision.isReversible ? "Reversible" : "Irreversible",
                               icon: decision.isReversible ? "arrow.uturn.backward" : "lock.fill",
                               color: decision.isReversible ? HindsightTheme.Colors.success : HindsightTheme.Colors.textSecondary)
                    }
                    if let reviewedAt = decision.outcomeReview?.reviewedAt {
                        Text("Reviewed \(reviewedAt.formatted(.dateTime.month(.wide).day().year()))")
                            .font(HindsightTheme.Typography.caption)
                            .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    }
                }
                Spacer(minLength: 0)

                HProgressRing(
                    progress: Double(decision.clarityScore) / 100,
                    lineWidth: 8, size: 76,
                    tint: HindsightTheme.Colors.amber,
                    label: "\(decision.clarityScore)", caption: "context",
                    accessibilityLabel: "Context captured",
                    accessibilityValue: "\(decision.clarityScore) out of 100"
                )
            }

            if let chosen = decision.chosenOptionTitle {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(HindsightTheme.Colors.success)
                    Text("You chose: ").foregroundStyle(HindsightTheme.Colors.textSecondary)
                        + Text(chosen).foregroundStyle(HindsightTheme.Colors.textPrimary).bold()
                }
                .font(HindsightTheme.Typography.footnote)
            }
        }
    }

    // MARK: Timeline

    private var timeline: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                HSectionHeader(title: "Timeline", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                HStack(alignment: .top, spacing: 0) {
                    timelineStep("Created", date: decision.createdAt, done: true, isFirst: true)
                    timelineConnector(done: decision.decidedAt != nil)
                    timelineStep("Decided", date: decision.decidedAt, done: decision.decidedAt != nil)
                    timelineConnector(done: decision.status != .active)
                    timelineStep("Review", date: decision.dueDate, done: decision.status != .active,
                                 highlight: decision.needsReview)
                    timelineConnector(done: decision.status == .reviewed)
                    timelineStep("Reviewed", date: decision.outcomeReview?.reviewedAt,
                                 done: decision.status == .reviewed, isLast: true)
                }
            }
        }
    }

    private func timelineStep(_ title: String, date: Date?, done: Bool,
                              isFirst: Bool = false, isLast: Bool = false,
                              highlight: Bool = false) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(done ? (highlight ? HindsightTheme.Colors.accent : HindsightTheme.Colors.success)
                               : HindsightTheme.Colors.cardElevated)
                    .frame(width: 26, height: 26)
                Image(systemName: done ? "checkmark" : "circle.fill")
                    .font(.system(size: done ? 12 : 6, weight: .bold))
                    .foregroundStyle(done ? .white : HindsightTheme.Colors.textTertiary)
            }
            Text(title)
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(done ? HindsightTheme.Colors.textPrimary : HindsightTheme.Colors.textTertiary)
            Text(date.map { $0.formatted(.dateTime.month(.abbreviated).day()) } ?? "—")
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
        }
        .fixedSize()
    }

    private func timelineConnector(done: Bool) -> some View {
        Rectangle()
            .fill(done ? HindsightTheme.Colors.success : HindsightTheme.Colors.cardElevated)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .offset(y: -25)
    }

    // MARK: Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Context", systemImage: "text.alignleft")
            HCard {
                Text(decision.notes)
                    .font(HindsightTheme.Typography.body)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Options

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Options", subtitle: "What you weighed",
                           systemImage: "square.stack.3d.up.fill")
            if decision.options.isEmpty {
                Text("No options recorded.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            } else {
                ForEach(decision.options) { option in
                    OptionDetailCard(
                        option: option,
                        isChosen: option.title == decision.chosenOptionTitle,
                        isExpanded: expandedOptionID == option.id,
                        canChoose: decision.status != .reviewed,
                        onToggle: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                expandedOptionID = expandedOptionID == option.id ? nil : option.id
                            }
                        },
                        onChoose: { chooseOption(option) }
                    )
                }
            }
        }
    }

    // MARK: Predictions

    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Predictions", subtitle: "What you believed would happen",
                           systemImage: "scope")
            if decision.predictions.isEmpty {
                Text("No predictions recorded.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            } else {
                ForEach(decision.sortedPredictions) { prediction in
                    PredictionCardView(prediction: prediction)
                }
            }
        }
    }

    // MARK: Outcome

    private var outcomeSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Outcome", systemImage: "flag.checkered")

            if let review = decision.outcomeReview {
                OutcomeSummaryCard(review: review)
            } else if allPredictionsHaveTerminalOutcomes {
                HCard(background: HindsightTheme.Colors.success.opacity(0.10)) {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                        Label("Forecast outcome recorded", systemImage: "checkmark.circle.fill")
                            .font(HindsightTheme.Typography.headline)
                            .foregroundStyle(HindsightTheme.Colors.success)
                        Text(terminalOutcomeDetail)
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        HButton(title: "Add Optional Reflection", icon: "square.and.pencil", style: .secondary) {
                            showOutcomeReview = true
                        }
                    }
                }
            } else if decision.isPastDue {
                HCard(background: HindsightTheme.Colors.accent.opacity(0.12)) {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                        HStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill").foregroundStyle(HindsightTheme.Colors.accent)
                            Text("Ready for a look back")
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        }
                        Text("Your review date has passed. Start with the predictions you recorded, or add a fuller reflection.")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        if hasDuePendingPredictions {
                            HButton(title: "Resolve Predictions", icon: "scope") { showDuePredictionStack = true }
                        }
                        HButton(title: "Write Full Review", icon: "square.and.pencil", style: .secondary) { showOutcomeReview = true }
                    }
                }
            } else {
                HCard {
                    HStack(spacing: 10) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 22))
                            .foregroundStyle(HindsightTheme.Colors.amber)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Awaiting review")
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            Text("Set for \(decision.dueDate.formatted(.dateTime.month(.wide).day().year()))")
                                .font(HindsightTheme.Typography.footnote)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                        Spacer()
                        Button("Review early") { showOutcomeReview = true }
                            .font(HindsightTheme.Typography.subheadline)
                            .tint(HindsightTheme.Colors.accent)
                    }
                }
            }
        }
    }

    private var hasDuePendingPredictions: Bool {
        decision.predictions.contains { $0.status == .pending && $0.dueDate <= Date() }
    }

    private var allPredictionsHaveTerminalOutcomes: Bool {
        !decision.predictions.isEmpty && decision.predictions.allSatisfy { $0.status != .pending }
    }

    private var terminalOutcomeDetail: String {
        if decision.predictions.contains(where: { $0.dueDate > Date() }) {
            return "The result is saved. Forecasts enter calibration only after their original check date arrives. A fuller reflection is optional."
        }
        return "The result is saved in History and is eligible for calibration when binary. Add a fuller reflection if it would help you learn from the decision."
    }

    // MARK: Actions

    private func chooseOption(_ option: DecisionOption) {
        decision.chosenOptionTitle = option.title
        if decision.status == .active {
            markDecided()
        }

        // Attempt save; side effects (haptic) only on success
        if PersistenceService.saveOrReport(context) {
            HapticsManager.shared.optionCommitted()
        } else {
            saveError = "An error occurred while saving."
        }
    }

    private func markDecided() {
        decision.status = .awaitingReview
        decision.decidedAt = Date()

        // Attempt save; side effects (reminder scheduling) only on success
        if PersistenceService.saveOrReport(context) {
            Task { await notificationManager.scheduleReviewReminderIfAllowed(for: decision) }
        } else {
            saveError = "An error occurred while saving."
        }
    }

    private func deleteDecision() {
        switch DataLifecycleManager.deleteDecision(decision, in: context) {
        case .deleted(let receipt):
            notificationManager.cancelReminders(withIdentifiers: receipt.reminderIdentifiers)
            HapticsManager.shared.deleteConfirmed()
            dismiss()
        case .failed:
            deleteError = "The decision and its forecasts were not deleted. They are unchanged and ready to retry."
        }
    }
}

// MARK: - Option detail card

private struct OptionDetailCard: View {
    let option: DecisionOption
    let isChosen: Bool
    let isExpanded: Bool
    let canChoose: Bool
    let onToggle: () -> Void
    let onChoose: () -> Void

    var body: some View {
        HCard(background: isChosen ? HindsightTheme.Colors.success.opacity(0.12) : HindsightTheme.Colors.card) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                Button(action: onToggle) {
                    HStack(spacing: HindsightTheme.Spacing.sm) {
                        Image(systemName: isChosen ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(isChosen ? HindsightTheme.Colors.success : HindsightTheme.Colors.textTertiary)
                        Text(option.title)
                            .font(HindsightTheme.Typography.headline)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                        HStarRating(value: option.gutFeeling, size: 13)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(HindsightTheme.Colors.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                        if !option.upside.isEmpty {
                            tradeoffRow(icon: "plus.circle.fill", color: HindsightTheme.Colors.success,
                                        label: "Upside", text: option.upside)
                        }
                        if !option.downside.isEmpty {
                            tradeoffRow(icon: "minus.circle.fill", color: HindsightTheme.Colors.accent,
                                        label: "Downside", text: option.downside)
                        }
                        HStack(spacing: HindsightTheme.Spacing.lg) {
                            HMeter(label: "Effort", value: option.effortLevel, tint: HindsightTheme.Colors.amber)
                            HMeter(label: "Risk", value: option.riskLevel, tint: HindsightTheme.Colors.accent)
                        }
                        if canChoose && !isChosen {
                            HButton(title: "Choose this option", icon: "checkmark", style: .secondary, action: onChoose)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func tradeoffRow(icon: String, color: Color, label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).foregroundStyle(color).font(.system(size: 14))
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(HindsightTheme.Typography.caption2)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                Text(text)
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Outcome summary card

private struct OutcomeSummaryCard: View {
    let review: OutcomeReview

    var body: some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                if review.hasOutcomeQuality || review.hasDecisionQuality || review.hasWouldDoAgain {
                    HStack {
                        if review.hasOutcomeQuality {
                            ratingColumn("Outcome", value: review.outcomeQuality, tint: HindsightTheme.Colors.success)
                        }
                        if review.hasOutcomeQuality && (review.hasDecisionQuality || review.hasWouldDoAgain) {
                            Divider().frame(height: 40).overlay(HindsightTheme.Colors.border)
                        }
                        if review.hasDecisionQuality {
                            ratingColumn("Process", value: review.decisionQuality, tint: HindsightTheme.Colors.amber)
                        }
                        if review.hasDecisionQuality && review.hasWouldDoAgain {
                            Divider().frame(height: 40).overlay(HindsightTheme.Colors.border)
                        }
                        if review.hasWouldDoAgain {
                            VStack(spacing: 4) {
                                Text("Again?").font(HindsightTheme.Typography.caption2)
                                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                                Image(systemName: review.wouldDoAgain ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(review.wouldDoAgain ? HindsightTheme.Colors.success : HindsightTheme.Colors.accent)
                            }
                            .frame(maxWidth: .infinity)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Would make the same decision again")
                            .accessibilityValue(review.wouldDoAgain ? "Yes" : "No")
                        }
                    }
                } else {
                    Text("No optional ratings recorded")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }

                if !review.whatHappened.isEmpty {
                    labelled("What happened", review.whatHappened)
                }
                if !review.whatSurprised.isEmpty {
                    labelled("What surprised you", review.whatSurprised)
                }
                if !review.mainLesson.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill").foregroundStyle(HindsightTheme.Colors.amber)
                        Text(review.mainLesson)
                            .font(HindsightTheme.Typography.callout)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .italic()
                    }
                    .padding(HindsightTheme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(HindsightTheme.Colors.amber.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm))
                }

                Text("Reviewed \(review.reviewedAt.formatted(.dateTime.month(.wide).day().year()))")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            }
        }
    }

    private func ratingColumn(_ title: String, value: Int, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(HindsightTheme.Typography.caption2)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
            Text("\(value)/5").font(HindsightTheme.Typography.title2).foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity)
    }

    private func labelled(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(HindsightTheme.Typography.caption2)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
            Text(text)
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        DecisionDetailView(decision: try! SampleData.previewContainer.mainContext.fetch(FetchDescriptor<Decision>()).first!)
    }
    .environmentObject(NotificationManager.shared)
    .modelContainer(SampleData.previewContainer)
}
