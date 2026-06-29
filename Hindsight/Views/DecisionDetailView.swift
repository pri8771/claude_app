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
    @State private var showDeleteConfirm = false
    @State private var expandedOptionID: UUID?

    var body: some View {
        ZStack {
            HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
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
                .accessibilityLabel("More actions")
            }
        }
        .sheet(isPresented: $showOutcomeReview) {
            OutcomeReviewView(decision: decision)
        }
        .confirmationDialog("Delete this decision?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteDecision() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes the decision and its predictions. This can't be undone.")
        }
    }

    // MARK: Header

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
                }
                Spacer(minLength: 0)

                HProgressRing(
                    progress: Double(decision.clarityScore) / 100,
                    lineWidth: 8, size: 76,
                    tint: HindsightTheme.Colors.amber,
                    label: "\(decision.clarityScore)", caption: "clarity"
                )
            }

            if let chosen = decision.chosenOptionDisplayTitle {
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
                .font(.system(size: 10, weight: .medium, design: .rounded))
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
                        isChosen: decision.isChosen(option),
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
            } else if decision.isPastDue {
                HCard(background: HindsightTheme.Colors.accent.opacity(0.12)) {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                        HStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill").foregroundStyle(HindsightTheme.Colors.accent)
                            Text("Reality has arrived")
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        }
                        Text("Your review date has passed. Look back and grade how this decision actually played out.")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        HButton(title: "Review Now", icon: "square.and.pencil") { showOutcomeReview = true }
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

    // MARK: Actions

    private func chooseOption(_ option: DecisionOption) {
        decision.chosenOptionID = option.id
        decision.chosenOptionTitle = option.title
        if decision.status == .active {
            // Transition to awaiting-review and schedule the reminder without
            // an extra redundant save (this method saves once at the end).
            decision.status = .awaitingReview
            decision.decidedAt = Date()
            notificationManager.scheduleReviewReminder(for: decision)
        }
        context.saveChanges()
        HapticsManager.shared.optionCommitted()
    }

    private func markDecided() {
        decision.status = .awaitingReview
        decision.decidedAt = Date()
        notificationManager.scheduleReviewReminder(for: decision)
        context.saveChanges()
    }

    private func deleteDecision() {
        HapticsManager.shared.deleteConfirmed()
        notificationManager.cancelReminder(for: decision)
        context.delete(decision)
        context.saveChanges()
        dismiss()
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
                HStack {
                    ratingColumn("Outcome", value: review.outcomeQuality, tint: HindsightTheme.Colors.success)
                    Divider().frame(height: 40).overlay(HindsightTheme.Colors.border)
                    ratingColumn("Process", value: review.decisionQuality, tint: HindsightTheme.Colors.amber)
                    Divider().frame(height: 40).overlay(HindsightTheme.Colors.border)
                    VStack(spacing: 4) {
                        Text("Again?").font(HindsightTheme.Typography.caption2)
                            .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        Image(systemName: review.wouldDoAgain ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(review.wouldDoAgain ? HindsightTheme.Colors.success : HindsightTheme.Colors.accent)
                    }
                    .frame(maxWidth: .infinity)
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
    .preferredColorScheme(.dark)
}
