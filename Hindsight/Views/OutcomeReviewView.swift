//
//  OutcomeReviewView.swift
//  Hindsight
//
//  The retrospective form: what actually happened, how good the result
//  and the process were, what surprised you, the lesson learned, and a
//  verdict on every prediction.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct OutcomeReviewView: View {
    @Bindable var decision: Decision

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager

    // Form state
    @State private var whatHappened = ""
    @State private var outcomeQuality = 3
    @State private var decisionQuality = 3
    @State private var wouldDoAgain = true
    @State private var whatSurprised = ""
    @State private var mainLesson = ""
    @State private var predictionVerdicts: [UUID: PredictionStatus] = [:]
    @State private var predictionResults: [UUID: String] = [:]
    @State private var showValidationHint = false

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                        intro
                        whatHappenedSection
                        ratingsSection
                        reflectionSection
                        predictionsSection
                        HButton(title: "Save Review", icon: "checkmark.seal.fill") { save() }
                            .padding(.top, HindsightTheme.Spacing.sm)
                        Color.clear.frame(height: 12)
                    }
                    .padding(HindsightTheme.Spacing.md)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Outcome Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.tint(HindsightTheme.Colors.textSecondary)
                }
            }
            .onAppear(perform: seedExistingReview)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Sections

    private var intro: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(decision.title)
                .font(HindsightTheme.Typography.title2)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text("Grade how this actually played out.")
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
    }

    private var whatHappenedSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "What actually happened?", systemImage: "text.bubble.fill")
            HTextEditor(text: $whatHappened, placeholder: "Describe how it turned out…",
                        accessibilityIdentifier: "outcomeReview.whatHappened")
            if showValidationHint {
                Label("Add a line about what happened before saving.", systemImage: "exclamationmark.circle.fill")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.amber)
                    .transition(.opacity)
            }
        }
    }

    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            HCard {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("Was the result good?")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Judge the outcome itself — even good decisions can get unlucky.")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    HStarRating(rating: $outcomeQuality, size: 34, tint: HindsightTheme.Colors.success)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }

            HCard {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("Was your decision-making good?")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Judge the process you followed, regardless of luck.")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    HStarRating(rating: $decisionQuality, size: 34, tint: HindsightTheme.Colors.amber)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }

            HCard {
                Toggle(isOn: $wouldDoAgain) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Would you make the same decision again?")
                            .font(HindsightTheme.Typography.headline)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        Text(wouldDoAgain ? "Yes — knowing what you know now" : "No — you'd choose differently")
                            .font(HindsightTheme.Typography.caption)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                }
                .tint(HindsightTheme.Colors.success)
            }
        }
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "What surprised you?", systemImage: "sparkle.magnifyingglass")
                HTextEditor(text: $whatSurprised, placeholder: "Anything you didn't see coming…", minHeight: 80)
            }
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Main lesson learned", systemImage: "lightbulb.fill")
                HTextEditor(text: $mainLesson, placeholder: "The one thing to remember next time…", minHeight: 80)
            }
        }
    }

    @ViewBuilder private var predictionsSection: some View {
        if !decision.predictions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Grade your predictions",
                               subtitle: "How did past you do?", systemImage: "scope")
                ForEach(decision.predictions) { prediction in
                    PredictionVerdictRow(
                        prediction: prediction,
                        verdict: Binding(
                            get: { predictionVerdicts[prediction.id] ?? .correct },
                            set: { predictionVerdicts[prediction.id] = $0 }
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

    // MARK: Persistence

    private func seedExistingReview() {
        if let review = decision.outcomeReview {
            whatHappened = review.whatHappened
            outcomeQuality = review.outcomeQuality
            decisionQuality = review.decisionQuality
            wouldDoAgain = review.wouldDoAgain
            whatSurprised = review.whatSurprised
            mainLesson = review.mainLesson
        }
        for prediction in decision.predictions {
            predictionVerdicts[prediction.id] = prediction.status == .pending ? .correct : prediction.status
            predictionResults[prediction.id] = prediction.actualResult ?? ""
        }
    }

    private func save() {
        // Gentle validation: a review should at least say what happened.
        guard !whatHappened.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            withAnimation { showValidationHint = true }
            HapticsManager.shared.validationWarning()
            return
        }

        let review = decision.outcomeReview ?? OutcomeReview()
        review.whatHappened = whatHappened
        review.outcomeQuality = outcomeQuality
        review.decisionQuality = decisionQuality
        review.wouldDoAgain = wouldDoAgain
        review.whatSurprised = whatSurprised
        review.mainLesson = mainLesson
        review.reviewedAt = Date()

        if decision.outcomeReview == nil {
            review.decision = decision
            decision.outcomeReview = review
            context.insert(review)
        }

        for prediction in decision.predictions {
            prediction.status = predictionVerdicts[prediction.id] ?? .correct
            let result = predictionResults[prediction.id]?.trimmingCharacters(in: .whitespacesAndNewlines)
            prediction.actualResult = (result?.isEmpty == false) ? result : nil
            notificationManager.cancelReminder(for: prediction)
        }

        decision.status = .reviewed
        notificationManager.cancelReminder(for: decision)
        try? context.save()

        HapticsManager.shared.outcomeReviewed()
        dismiss()
    }
}

// MARK: - Prediction verdict row

private struct PredictionVerdictRow: View {
    let prediction: Prediction
    @Binding var verdict: PredictionStatus
    @Binding var result: String

    private let options: [PredictionStatus] = [.correct, .partial, .incorrect]

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

                HStack(spacing: 6) {
                    ForEach(options) { status in
                        Button {
                            verdict = status
                            switch status {
                            case .correct:   HapticsManager.shared.predictionResolvedCorrect()
                            case .incorrect: HapticsManager.shared.predictionResolvedIncorrect()
                            default:         HapticsManager.shared.selectionChanged()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: status.icon).font(.system(size: 11, weight: .bold))
                                Text(status.rawValue).font(HindsightTheme.Typography.caption)
                            }
                            .foregroundStyle(verdict == status ? .white : status.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(verdict == status ? status.color : status.color.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HTextField(text: $result, placeholder: "What actually happened? (optional)")
            }
        }
    }
}

#Preview {
    OutcomeReviewView(decision: try! SampleData.previewContainer.mainContext.fetch(FetchDescriptor<Decision>()).first!)
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
