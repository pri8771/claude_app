//
//  InsightsView.swift
//  Hindsight
//
//  Signal Garden turns a private calibration record into an inviting visual
//  story. Every value still comes from Statistics' strict, sample-safe
//  snapshot; presentation never re-selects or re-scores forecasts.
//

import SwiftUI
import SwiftData
import Foundation

struct InsightsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]

    private var analytics: ForecastAnalyticsSnapshot {
        Statistics.forecastAnalytics(decisions)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.background.ignoresSafeArea()

                if decisions.isEmpty {
                    signalGardenEmptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xl) {
                            SignalGardenHero(metric: analytics.overall)
                                .accessibilityIdentifier("insights.signalGarden.hero")
                            evidenceMilestones
                            highConfidenceTruth
                                .accessibilityIdentifier("insights.highConfidence")
                            confidenceBandGarden
                                .accessibilityIdentifier("insights.confidenceBands")
                            personalSignals
                                .accessibilityIdentifier("insights.personalSignals")
                            recentReflections
                            methodology
                                .accessibilityIdentifier("insights.methodology")
                            Color.clear.frame(height: HindsightTheme.Spacing.md)
                        }
                        .padding(HindsightTheme.Spacing.md)
                        .hindsightReadableWidth()
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Insights")
            .navigationDestination(for: Decision.self) { DecisionDetailView(decision: $0) }
        }
    }

    // MARK: - Empty and evidence progress

    private var signalGardenEmptyState: some View {
        VStack(spacing: HindsightTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(HindsightTheme.Colors.border, lineWidth: 12)
                    .frame(width: 132, height: 132)
                Circle()
                    .trim(from: 0, to: 0.18)
                    .stroke(HindsightTheme.Colors.steel, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 132, height: 132)
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(HindsightTheme.Colors.steel)
            }
            VStack(spacing: HindsightTheme.Spacing.sm) {
                Text("Your signal garden starts here")
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Capture a forecast, state your confidence, then resolve what happened. Insights grow only from your eligible personal outcomes.")
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HindsightTheme.Spacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("insights.empty")
    }

    private var evidenceMilestones: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            SignalSectionHeading(
                eyebrow: "EVIDENCE IN MOTION",
                title: milestoneTitle,
                detail: sampleQualification(analytics.overall),
                color: HindsightTheme.Colors.categoryEducation
            )
            SignalMilestoneRail(count: analytics.overall.eligibleCount)
        }
    }

    private var milestoneTitle: String {
        switch analytics.overall.sampleState {
        case .noEvidence: return "Resolve one forecast to plant the first signal"
        case .learning: return "A pattern is beginning to take root"
        case .earlySignal: return "The early shape is visible"
        case .directional: return "Your calibration record can support a directional read"
        }
    }

    // MARK: - High-confidence truth

    private var highConfidenceTruth: some View {
        let metric = analytics.highConfidence.metric
        return VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            SignalSectionHeading(
                eyebrow: "WHEN YOU FELT SURE",
                title: "80%+ confidence, meet reality",
                detail: "Only personal, due, binary outcomes. This card always shows its own denominator.",
                color: HindsightTheme.Colors.accent
            )

            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                if metric.eligibleCount == 0 {
                    LockedSignal(
                        icon: "sun.max.trianglebadge.exclamationmark",
                        title: "No eligible high-confidence outcomes yet",
                        detail: "Resolve a due forecast originally recorded between 80% and 100% confidence to begin this view.",
                        footer: "n = 0 in the 80–100% band"
                    )
                } else {
                    Text(highConfidenceStory(metric))
                        .font(HindsightTheme.Typography.authoredStatement)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: HindsightTheme.Spacing.sm) {
                            SignalMetricTile(
                                value: insightPercent(metric.meanConfidence),
                                label: "Mean stated confidence",
                                color: HindsightTheme.Colors.accent
                            )
                            SignalMetricTile(
                                value: insightPercent(metric.observedRate),
                                label: "Observed outcome rate",
                                color: HindsightTheme.Colors.success
                            )
                            SignalMetricTile(
                                value: insightSignedPoints(metric.signedGap),
                                label: "Observed − confidence",
                                color: insightGapColor(metric.signedGap)
                            )
                        }
                        VStack(spacing: HindsightTheme.Spacing.sm) {
                            SignalMetricTile(value: insightPercent(metric.meanConfidence), label: "Mean stated confidence", color: HindsightTheme.Colors.accent)
                            SignalMetricTile(value: insightPercent(metric.observedRate), label: "Observed outcome rate", color: HindsightTheme.Colors.success)
                            SignalMetricTile(value: insightSignedPoints(metric.signedGap), label: "Observed − confidence", color: insightGapColor(metric.signedGap))
                        }
                    }

                    HStack {
                        Label("n = \(metric.eligibleCount)", systemImage: "number")
                        Spacer()
                        Text(sampleStateLabel(metric.sampleState))
                    }
                    .font(HindsightTheme.Typography.metadata)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .monospacedDigit()
                }
            }
            .padding(HindsightTheme.Spacing.lg)
            .background(HindsightTheme.Colors.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .stroke(HindsightTheme.Colors.accent.opacity(0.35), lineWidth: 1)
            }
        }
    }

    // MARK: - Confidence bands

    private var confidenceBandGarden: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            SignalSectionHeading(
                eyebrow: "YOUR CONFIDENCE LANDSCAPE",
                title: "Where belief and outcomes line up",
                detail: "Every fixed band stays in place. Filled bars are observed outcomes; outlined markers are mean stated confidence.",
                color: HindsightTheme.Colors.amber
            )

            VStack(spacing: HindsightTheme.Spacing.sm) {
                ForEach(analytics.confidenceBands) { summary in
                    ConfidenceBandSignalRow(summary: summary)
                }
            }
        }
    }

    // MARK: - Personal signals

    private var personalSignals: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            SignalSectionHeading(
                eyebrow: "PERSONAL SIGNALS",
                title: "Context changes the picture",
                detail: "These are observations from eligible cohorts—not labels about you. Each cohort needs n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize).",
                color: HindsightTheme.Colors.categoryPersonal
            )

            LazyVGrid(columns: patternColumns, spacing: HindsightTheme.Spacing.sm) {
                SignalPatternCard(model: momentumPattern)

                if let surprisePattern {
                    SignalPatternCard(model: surprisePattern)
                } else {
                    LockedPatternCard(
                        title: "A confidence-band surprise",
                        detail: "Unlocks when at least one fixed confidence band reaches n = 10.",
                        color: HindsightTheme.Colors.amber
                    )
                }

                if categoryPatterns.isEmpty {
                    LockedPatternCard(
                        title: "Signals by life area",
                        detail: "Each category appears only after n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize) eligible forecasts in that category.",
                        color: HindsightTheme.Colors.categoryCareer
                    )
                } else {
                    ForEach(categoryPatterns) { SignalPatternCard(model: $0) }
                }

                if horizonPatterns.isEmpty {
                    LockedPatternCard(
                        title: "Short calls vs long calls",
                        detail: "Each time horizon appears only after n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize) eligible forecasts.",
                        color: HindsightTheme.Colors.categoryEducation
                    )
                } else {
                    ForEach(horizonPatterns) { SignalPatternCard(model: $0) }
                }

                if let reasoningPattern {
                    SignalPatternCard(model: reasoningPattern)
                } else {
                    LockedPatternCard(
                        title: "Does writing Why change the record?",
                        detail: "This comparison waits until both With Why and Without Why have n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize).",
                        color: HindsightTheme.Colors.success
                    )
                }
            }
        }
    }

    private var momentumPattern: SignalPatternCardModel {
        let metric = analytics.overall
        let title: String
        let detail: String
        switch metric.sampleState {
        case .noEvidence:
            title = "The first signal is waiting"
            detail = "No eligible personal outcomes yet. One resolved due binary forecast begins the record."
        case .learning:
            title = "\(metric.eligibleCount) of 5 toward an early shape"
            detail = "Current evidence: n = \(metric.eligibleCount). Measurements remain descriptive until the sample grows."
        case .earlySignal:
            title = "\(metric.eligibleCount) of 10 toward a directional read"
            detail = "An early signal is visible, but Hindsight still withholds a directional conclusion."
        case .directional:
            title = "A directional record is active"
            detail = "Based on n = \(metric.eligibleCount) eligible outcomes; mean confidence \(insightPercent(metric.meanConfidence)), observed \(insightPercent(metric.observedRate))."
        }
        return SignalPatternCardModel(
            id: "momentum",
            eyebrow: "EVIDENCE MOMENTUM · n = \(metric.eligibleCount)",
            title: title,
            detail: detail,
            icon: "leaf.arrow.triangle.circlepath",
            color: HindsightTheme.Colors.categoryPersonal
        )
    }

    private var surprisePattern: SignalPatternCardModel? {
        guard let summary = analytics.confidenceBands
            .filter({ $0.metric.sampleState == .directional })
            .max(by: { abs($0.metric.signedGap) < abs($1.metric.signedGap) }) else { return nil }
        let metric = summary.metric
        let title = abs(metric.signedGap) < 0.005
            ? "\(summary.band.rawValue) matched closely"
            : "\(summary.band.rawValue) showed the widest band gap"
        return SignalPatternCardModel(
            id: "surprise-\(summary.id)",
            eyebrow: "BAND SIGNAL · n = \(metric.eligibleCount)",
            title: title,
            detail: "Mean confidence \(insightPercent(metric.meanConfidence)); observed outcome \(insightPercent(metric.observedRate)); gap \(insightSignedPoints(metric.signedGap)).",
            icon: "sparkle.magnifyingglass",
            color: confidenceBandColor(summary.band)
        )
    }

    private var categoryPatterns: [SignalPatternCardModel] {
        analytics.categoryCohorts
            .sorted { abs($0.metric.signedGap) > abs($1.metric.signedGap) }
            .prefix(2)
            .map { cohort in
                SignalPatternCardModel(
                    id: "category-\(cohort.id)",
                    eyebrow: "CATEGORY · n = \(cohort.metric.eligibleCount)",
                    title: cohort.category.rawValue,
                    detail: "Mean confidence \(insightPercent(cohort.metric.meanConfidence)); observed \(insightPercent(cohort.metric.observedRate)); gap \(insightSignedPoints(cohort.metric.signedGap)).",
                    icon: cohort.category.icon,
                    color: cohort.category.color
                )
            }
    }

    private var horizonPatterns: [SignalPatternCardModel] {
        analytics.horizonCohorts
            .sorted { abs($0.metric.signedGap) > abs($1.metric.signedGap) }
            .prefix(2)
            .map { cohort in
                SignalPatternCardModel(
                    id: "horizon-\(cohort.id)",
                    eyebrow: "HORIZON · n = \(cohort.metric.eligibleCount)",
                    title: cohort.horizon.rawValue,
                    detail: "Mean confidence \(insightPercent(cohort.metric.meanConfidence)); observed \(insightPercent(cohort.metric.observedRate)); gap \(insightSignedPoints(cohort.metric.signedGap)).",
                    icon: "calendar.badge.clock",
                    color: HindsightTheme.Colors.categoryEducation
                )
            }
    }

    private var reasoningPattern: SignalPatternCardModel? {
        guard analytics.reasoningCohorts.count == 2,
              let without = analytics.reasoningCohorts.first(where: { !$0.hasReasoning }),
              let with = analytics.reasoningCohorts.first(where: { $0.hasReasoning }) else { return nil }
        return SignalPatternCardModel(
            id: "reasoning",
            eyebrow: "WHY COMPARISON · n = \(without.metric.eligibleCount) + \(with.metric.eligibleCount)",
            title: "With Why vs without Why",
            detail: "Observed outcome: \(insightPercent(with.metric.observedRate)) with Why and \(insightPercent(without.metric.observedRate)) without. Gaps: \(insightSignedPoints(with.metric.signedGap)) vs \(insightSignedPoints(without.metric.signedGap)). This is association, not causation.",
            icon: "text.quote",
            color: HindsightTheme.Colors.success
        )
    }

    // MARK: - Recent reflections and methodology

    @ViewBuilder private var recentReflections: some View {
        let reviewed = Statistics.reviewedDecisions(decisions)
            .filter { !SampleData.isDemoDecision($0) }
            .sorted { ($0.outcomeReview?.reviewedAt ?? .distantPast) > ($1.outcomeReview?.reviewedAt ?? .distantPast) }
            .prefix(3)

        if !reviewed.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                SignalSectionHeading(
                    eyebrow: "RECENT REFLECTIONS",
                    title: "The stories behind the signal",
                    detail: "Open an original record without changing what you believed.",
                    color: HindsightTheme.Colors.steel
                )

                ForEach(Array(reviewed)) { decision in
                    NavigationLink(value: decision) {
                        HStack(spacing: HindsightTheme.Spacing.md) {
                            ZStack {
                                Circle().fill(decision.category.color.opacity(0.16))
                                Image(systemName: decision.category.icon)
                                    .foregroundStyle(decision.category.color)
                            }
                            .frame(width: 46, height: 46)
                            .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(decision.title)
                                    .font(HindsightTheme.Typography.callout)
                                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Reviewed \(decision.outcomeReview?.reviewedAt.formatted(date: .abbreviated, time: .omitted) ?? "recently")")
                                    .font(HindsightTheme.Typography.caption)
                                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        }
                        .padding(HindsightTheme.Spacing.md)
                        .background(decision.category.color.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                                .stroke(decision.category.color.opacity(0.24), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var methodology: some View {
        let exclusions = analytics.exclusions
        return VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            SignalSectionHeading(
                eyebrow: "WHAT COUNTS",
                title: "A transparent evidence boundary",
                detail: "\(analytics.overall.eligibleCount) of \(exclusions.totalPredictions) stored forecasts are eligible. Nothing below is folded into the denominator.",
                color: HindsightTheme.Colors.steel
            )

            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                Text("Eligible means personal, due, valid 0–100% confidence, and a binary outcome: happened or did not happen.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                ExclusionLine(label: "Examples", count: exclusions.sample, color: HindsightTheme.Colors.amber)
                ExclusionLine(label: "Pending outcomes", count: exclusions.pending, color: HindsightTheme.Colors.steel)
                ExclusionLine(label: "Ambiguous outcomes", count: exclusions.partial, color: HindsightTheme.Colors.categoryEducation)
                ExclusionLine(label: "Resolved before check date", count: exclusions.notYetDue, color: HindsightTheme.Colors.categoryPersonal)
                ExclusionLine(label: "Invalid confidence", count: exclusions.invalidConfidence, color: HindsightTheme.Colors.accent)
                Divider().overlay(HindsightTheme.Colors.border)
                Text("Excluded total: \(exclusions.excludedCount). Brier score \(insightBrier(analytics.overall.meanBrierScore)) is mean squared probability error; lower is better. It is not an accuracy grade.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    .monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.cardElevated)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                    .stroke(HindsightTheme.Colors.border, lineWidth: 1)
            }
        }
    }

    // MARK: - Evidence language

    private func highConfidenceStory(_ metric: ForecastMetricSummary) -> String {
        if metric.sampleState == .directional {
            return "In \(metric.eligibleCount) resolved 80%+ forecasts, outcomes occurred \(insightPercent(metric.observedRate)) of the time against mean confidence of \(insightPercent(metric.meanConfidence))."
        }
        return "\(metric.eligibleCount) resolved 80%+ forecast\(metric.eligibleCount == 1 ? "" : "s") are measured so far. The values are real; the sample is not yet a conclusion."
    }

    private func sampleQualification(_ metric: ForecastMetricSummary) -> String {
        switch metric.sampleState {
        case .noEvidence:
            return "n = 0. Resolve a due forecast as happened or did not happen to begin."
        case .learning:
            return "n = \(metric.eligibleCount). Reach n = 5 for an early shape and n = 10 for a directional read."
        case .earlySignal:
            return "n = \(metric.eligibleCount). Early shape only; reach n = 10 before treating direction as a calibration read."
        case .directional:
            return "n = \(metric.eligibleCount). Observed minus confidence is \(insightSignedPoints(metric.signedGap))."
        }
    }

    private var patternColumns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible())]
            : [
                GridItem(.flexible(), spacing: HindsightTheme.Spacing.sm),
                GridItem(.flexible(), spacing: HindsightTheme.Spacing.sm)
            ]
    }
}

// MARK: - Signal Garden components

private struct SignalGardenHero: View {
    let metric: ForecastMetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                Text("YOUR SIGNAL GARDEN")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(0.9)
                    .foregroundStyle(HindsightTheme.Colors.categoryPersonal)
                Text(heroTitle)
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(heroDetail)
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: HindsightTheme.Spacing.xl) { orbit; heroMetrics }
                VStack(spacing: HindsightTheme.Spacing.lg) { orbit; heroMetrics }
            }
        }
        .padding(HindsightTheme.Spacing.lg)
        .background(HindsightTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .stroke(HindsightTheme.Colors.categoryPersonal.opacity(0.30), lineWidth: 1)
        }
    }

    private var orbit: some View {
        ZStack {
            Circle()
                .stroke(HindsightTheme.Colors.border, lineWidth: 13)
            Circle()
                .trim(from: 0, to: ringValue(metric.meanConfidence))
                .stroke(HindsightTheme.Colors.accent, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .stroke(HindsightTheme.Colors.border.opacity(0.75), lineWidth: 10)
                .frame(width: 116, height: 116)
            Circle()
                .trim(from: 0, to: ringValue(metric.observedRate))
                .stroke(HindsightTheme.Colors.success, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 116, height: 116)
            VStack(spacing: 0) {
                Text("n = \(metric.eligibleCount)")
                    .font(HindsightTheme.Typography.title2)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text("eligible")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
        .frame(width: 164, height: 164)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calibration orbit")
        .accessibilityValue("n \(metric.eligibleCount), mean confidence \(insightPercent(metric.meanConfidence)), observed outcome \(insightPercent(metric.observedRate))")
    }

    private var heroMetrics: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            OrbitLegend(color: HindsightTheme.Colors.accent, value: insightPercent(metric.meanConfidence), label: "You said")
            OrbitLegend(color: HindsightTheme.Colors.success, value: insightPercent(metric.observedRate), label: "It happened")
            Divider().overlay(HindsightTheme.Colors.border)
            OrbitLegend(color: insightGapColor(metric.signedGap), value: insightSignedPoints(metric.signedGap), label: "Observed − confidence")
            OrbitLegend(color: HindsightTheme.Colors.steel, value: insightBrier(metric.meanBrierScore), label: "Brier · lower is better")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroTitle: String {
        switch metric.sampleState {
        case .noEvidence: return "The shape of your judgment will appear here"
        case .learning: return "Reality has started answering back"
        case .earlySignal: return "Your first calibration shape is emerging"
        case .directional:
            if abs(metric.signedGap) < 0.05 { return "Confidence and outcomes are traveling close together" }
            return metric.signedGap < 0
                ? "Confidence is running ahead of observed outcomes"
                : "Observed outcomes are running ahead of confidence"
        }
    }

    private var heroDetail: String {
        guard metric.eligibleCount > 0 else {
            return "Only resolved, due, personal binary forecasts can draw this picture."
        }
        return "Across n = \(metric.eligibleCount) eligible forecasts, mean stated confidence is \(insightPercent(metric.meanConfidence)) and the observed outcome rate is \(insightPercent(metric.observedRate))."
    }

    private func ringValue(_ value: Double) -> Double {
        guard metric.eligibleCount > 0 else { return 0 }
        return max(0.002, min(1, value))
    }
}

private struct OrbitLegend: View {
    let color: Color
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            Circle().fill(color).frame(width: 10, height: 10).accessibilityHidden(true)
            Text(label)
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(HindsightTheme.Typography.subheadline)
                .monospacedDigit()
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct SignalSectionHeading: View {
    let eyebrow: String
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrow)
                .font(HindsightTheme.Typography.metadata)
                .tracking(0.7)
                .foregroundStyle(color)
            Text(title)
                .font(HindsightTheme.Typography.title2)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail)
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct SignalMilestoneRail: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let count: Int

    private let milestones = [(1, "First signal"), (5, "Early shape"), (10, "Directional")]

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    ForEach(Array(milestones.enumerated()), id: \.offset) { _, milestone in
                        milestoneView(milestone)
                    }
                }
            } else {
                HStack(spacing: HindsightTheme.Spacing.xs) {
                    ForEach(Array(milestones.enumerated()), id: \.offset) { index, milestone in
                        milestoneView(milestone)
                        if index < milestones.count - 1 {
                            Capsule()
                                .fill(count >= milestones[index + 1].0 ? HindsightTheme.Colors.categoryPersonal : HindsightTheme.Colors.border)
                                .frame(height: 3)
                                .accessibilityHidden(true)
                        }
                    }
                }
            }
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.categoryPersonal.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
    }

    private func milestoneView(_ milestone: (Int, String)) -> some View {
        let reached = count >= milestone.0
        return HStack(spacing: HindsightTheme.Spacing.sm) {
            ZStack {
                Circle().fill(reached ? HindsightTheme.Colors.categoryPersonal : HindsightTheme.Colors.cardElevated)
                Image(systemName: reached ? "checkmark" : "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(reached ? HindsightTheme.Colors.surface : HindsightTheme.Colors.textTertiary)
            }
            .frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(milestone.1)
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text("n = \(milestone.0)")
                    .font(HindsightTheme.Typography.metadata)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(reached ? "Reached" : "Locked; current n is \(count)")
    }
}

private struct SignalMetricTile: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(HindsightTheme.Typography.title2)
                .monospacedDigit()
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text(label)
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
        .padding(HindsightTheme.Spacing.sm)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous))
        .overlay(alignment: .leading) { Rectangle().fill(color).frame(width: 3) }
        .accessibilityElement(children: .combine)
    }
}

private struct ConfidenceBandSignalRow: View {
    let summary: ConfidenceBandSummary

    private var metric: ForecastMetricSummary { summary.metric }
    private var color: Color { confidenceBandColor(summary.band) }

    var body: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 8, height: 24)
                    Text(summary.band.rawValue)
                        .font(HindsightTheme.Typography.headline)
                        .monospacedDigit()
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                }
                Spacer()
                Text("n = \(metric.eligibleCount)")
                    .font(HindsightTheme.Typography.metadata)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }

            if metric.eligibleCount == 0 {
                HStack(spacing: HindsightTheme.Spacing.sm) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    Text("No resolved eligible forecasts in this band yet.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            } else {
                BandComparisonTrack(metric: metric, color: color)
                ViewThatFits(in: .horizontal) {
                    HStack {
                        bandLegend(color: color, label: "Observed", value: insightPercent(metric.observedRate), filled: true)
                        Spacer()
                        bandLegend(color: HindsightTheme.Colors.textPrimary, label: "Mean confidence", value: insightPercent(metric.meanConfidence), filled: false)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        bandLegend(color: color, label: "Observed", value: insightPercent(metric.observedRate), filled: true)
                        bandLegend(color: HindsightTheme.Colors.textPrimary, label: "Mean confidence", value: insightPercent(metric.meanConfidence), filled: false)
                    }
                }
                HStack {
                    Text(insightSignedPoints(metric.signedGap) + " gap")
                    Spacer()
                    Text(sampleStateLabel(metric.sampleState))
                }
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .monospacedDigit()
            }
        }
        .padding(HindsightTheme.Spacing.md)
        .background(color.opacity(metric.eligibleCount == 0 ? 0.035 : 0.075))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .stroke(color.opacity(metric.eligibleCount == 0 ? 0.15 : 0.32), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private func bandLegend(color: Color, label: String, value: String, filled: Bool) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(filled ? color : Color.clear)
                .overlay(Circle().stroke(color, lineWidth: 2))
                .frame(width: 9, height: 9)
            Text("\(label) \(value)")
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .monospacedDigit()
        }
    }

    private var accessibilitySummary: String {
        guard metric.eligibleCount > 0 else {
            return "\(summary.band.rawValue), n zero, no resolved eligible forecasts"
        }
        return "\(summary.band.rawValue), n \(metric.eligibleCount), observed \(insightPercent(metric.observedRate)), mean confidence \(insightPercent(metric.meanConfidence)), gap \(insightSignedPoints(metric.signedGap)), \(sampleStateLabel(metric.sampleState))"
    }
}

private struct BandComparisonTrack: View {
    let metric: ForecastMetricSummary
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(1, proxy.size.width)
            let observedX = width * min(1, max(0, metric.observedRate))
            let confidenceX = width * min(1, max(0, metric.meanConfidence))
            ZStack(alignment: .leading) {
                Capsule().fill(HindsightTheme.Colors.border).frame(height: 12)
                Capsule().fill(color.opacity(0.72)).frame(width: max(3, observedX), height: 12)
                Circle()
                    .fill(HindsightTheme.Colors.surface)
                    .overlay(Circle().stroke(HindsightTheme.Colors.textPrimary, lineWidth: 2))
                    .frame(width: 16, height: 16)
                    .offset(x: min(max(0, confidenceX - 8), max(0, width - 16)))
            }
            .frame(height: 20)
        }
        .frame(height: 20)
        .accessibilityHidden(true)
    }
}

private struct SignalPatternCardModel: Identifiable {
    let id: String
    let eyebrow: String
    let title: String
    let detail: String
    let icon: String
    let color: Color
}

private struct SignalPatternCard: View {
    let model: SignalPatternCardModel

    var body: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HStack {
                Image(systemName: model.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(model.color)
                    .frame(width: 38, height: 38)
                    .background(model.color.opacity(0.14), in: Circle())
                Spacer()
            }
            Text(model.eyebrow)
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(model.color)
                .fixedSize(horizontal: false, vertical: true)
            Text(model.title)
                .font(HindsightTheme.Typography.headline)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(model.detail)
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .padding(HindsightTheme.Spacing.md)
        .background(model.color.opacity(0.075))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .stroke(model.color.opacity(0.28), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct LockedPatternCard: View {
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: "lock.fill")
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12), in: Circle())
            Text("MORE EVIDENCE NEEDED")
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(color)
            Text(title)
                .font(HindsightTheme.Typography.headline)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(detail)
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.cardElevated.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .stroke(color.opacity(0.20), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        }
        .accessibilityElement(children: .combine)
    }
}

private struct LockedSignal: View {
    let icon: String
    let title: String
    let detail: String
    let footer: String

    var body: some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(HindsightTheme.Colors.accent)
                .frame(width: 48, height: 48)
                .background(HindsightTheme.Colors.accent.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(HindsightTheme.Typography.headline).foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(detail).font(HindsightTheme.Typography.footnote).foregroundStyle(HindsightTheme.Colors.textSecondary)
                Text(footer).font(HindsightTheme.Typography.metadata).monospacedDigit().foregroundStyle(HindsightTheme.Colors.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ExclusionLine: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            Circle().fill(color).frame(width: 8, height: 8).accessibilityHidden(true)
            Text(label).font(HindsightTheme.Typography.footnote).foregroundStyle(HindsightTheme.Colors.textSecondary)
            Spacer()
            Text("n = \(count)").font(HindsightTheme.Typography.metadata).monospacedDigit().foregroundStyle(HindsightTheme.Colors.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Formatting

private func insightPercent(_ value: Double) -> String {
    "\(Int((value * 100).rounded()))%"
}

private func insightSignedPoints(_ value: Double) -> String {
    let points = Int((value * 100).rounded())
    return "\(points >= 0 ? "+" : "")\(points) pp"
}

private func insightBrier(_ value: Double?) -> String {
    guard let value else { return "—" }
    return String(format: "%.3f", value)
}

private func insightGapColor(_ gap: Double) -> Color {
    if abs(gap) < 0.005 { return HindsightTheme.Colors.steel }
    return gap < 0 ? HindsightTheme.Colors.accent : HindsightTheme.Colors.success
}

private func sampleStateLabel(_ state: ForecastSampleState) -> String {
    switch state {
    case .noEvidence: return "No evidence yet"
    case .learning: return "Learning · below n = 5"
    case .earlySignal: return "Early signal · below n = 10"
    case .directional: return "Directional · n ≥ 10"
    }
}

private func confidenceBandColor(_ band: ConfidenceBand) -> Color {
    switch band {
    case .zeroToFortyNine: return HindsightTheme.Colors.steel
    case .fiftyToFiftyNine: return HindsightTheme.Colors.categoryEducation
    case .sixtyToSixtyNine: return HindsightTheme.Colors.categoryPersonal
    case .seventyToSeventyNine: return HindsightTheme.Colors.amber
    case .eightyToEightyNine: return HindsightTheme.Colors.categoryHealth
    case .ninetyToNinetyNine: return HindsightTheme.Colors.accent
    case .oneHundred: return HindsightTheme.Colors.stakesHigh
    }
}

#Preview {
    InsightsView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
