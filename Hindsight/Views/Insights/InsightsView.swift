//
//  InsightsView.swift
//  Hindsight
//
//  A private calibration instrument. All forecast figures come from the
//  sample-safe Statistics snapshot; this view never selects forecasts itself.
//

import SwiftUI
import SwiftData
import Charts
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
                    HEmptyState(
                        icon: "chart.xyaxis.line",
                        title: "No calibration record yet",
                        message: "Capture a forecast, then resolve whether it happened. Insights use only resolved binary outcomes."
                    )
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xl) {
                            calibrationOverview(analytics.overall)
                            highConfidenceSection(analytics.highConfidence.metric)
                            confidenceBandsSection(analytics.confidenceBands)
                            cohortSection(snapshot: analytics)
                            methodologySection(analytics)
                            recentReviewsSection
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

    // MARK: - Calibration record

    private func calibrationOverview(_ metric: ForecastMetricSummary) -> some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(
                title: "Calibration record",
                subtitle: "All time · strictly eligible binary forecasts",
                systemImage: "scope",
                tint: HindsightTheme.Colors.steel
            )

            HCard(background: HindsightTheme.Colors.surface) {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                    Text(overallStory(metric))
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(sampleQualification(metric))
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    metricGrid(metric)
                }
            }
        }
    }

    private func metricGrid(_ metric: ForecastMetricSummary) -> some View {
        LazyVGrid(
            columns: metricColumns,
            spacing: HindsightTheme.Spacing.sm
        ) {
            instrumentValue(value: countText(metric.eligibleCount), label: "Eligible forecasts", tint: HindsightTheme.Colors.steel)
            instrumentValue(value: percent(metric.meanConfidence), label: "Mean confidence", tint: HindsightTheme.Colors.accent)
            instrumentValue(value: percent(metric.observedRate), label: "Observed outcome", tint: HindsightTheme.Colors.success)
            instrumentValue(value: signedPoints(metric.signedGap), label: "Observed − confidence", tint: gapColor(metric.signedGap))
            instrumentValue(value: brierText(metric.meanBrierScore), label: "Brier score · lower is better", tint: HindsightTheme.Colors.steel)
        }
        .accessibilityElement(children: .contain)
    }

    private func instrumentValue(value: String, label: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
            Text(value)
                .font(HindsightTheme.Typography.title2)
                .monospacedDigit()
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(label)
                .font(HindsightTheme.Typography.caption)
                .foregroundStyle(tint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .padding(HindsightTheme.Spacing.sm)
        .background(HindsightTheme.Colors.card)
        .overlay(alignment: .leading) {
            Rectangle().fill(tint).frame(width: 2)
        }
        .accessibilityElement(children: .combine)
    }

    private func highConfidenceSection(_ metric: ForecastMetricSummary) -> some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(
                title: "High-confidence forecasts",
                subtitle: "Stated confidence from 80% to 100%",
                systemImage: "exclamationmark.circle",
                tint: HindsightTheme.Colors.accent
            )

            HCard {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text(highConfidenceStory(metric))
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if metric.eligibleCount > 0 {
                        Text("Mean confidence \(percent(metric.meanConfidence)); observed outcome \(percent(metric.observedRate)); signed gap \(signedPoints(metric.signedGap)).")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            .monospacedDigit()
                    }

                    Text(progressText(metric))
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        .monospacedDigit()
                }
            }
        }
    }

    // MARK: - Fixed confidence bands

    private func confidenceBandsSection(_ bands: [ConfidenceBandSummary]) -> some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(
                title: "Confidence bands",
                subtitle: "Fixed ranges; each row reports its own denominator",
                systemImage: "chart.bar.xaxis"
            )

            directionalCalibrationChart(bands)

            HCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(bands.enumerated()), id: \.element.id) { index, summary in
                        confidenceBandRow(summary)
                        if index < bands.count - 1 {
                            Divider().overlay(HindsightTheme.Colors.border)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func directionalCalibrationChart(_ bands: [ConfidenceBandSummary]) -> some View {
        let directional = bands.filter { $0.metric.sampleState == .directional }
        if !directional.isEmpty {
            HCard {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("Directional bands only")
                        .font(HindsightTheme.Typography.subheadline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Bars show observed outcome; points show mean stated confidence. Bands need n ≥ 10 to appear here.")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    Chart(directional) { summary in
                        BarMark(
                            x: .value("Confidence band", summary.band.rawValue),
                            y: .value("Observed outcome", summary.metric.observedRate * 100)
                        )
                        .foregroundStyle(HindsightTheme.Colors.success)

                        PointMark(
                            x: .value("Confidence band", summary.band.rawValue),
                            y: .value("Mean confidence", summary.metric.meanConfidence * 100)
                        )
                        .foregroundStyle(HindsightTheme.Colors.accent)
                        .symbolSize(42)
                    }
                    .chartYScale(domain: 0...100)
                    .chartYAxis {
                        AxisMarks(values: [0, 50, 100]) { value in
                            AxisGridLine().foregroundStyle(HindsightTheme.Colors.border)
                            AxisValueLabel {
                                if let number = value.as(Int.self) {
                                    Text("\(number)%")
                                        .font(HindsightTheme.Typography.caption2)
                                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let band = value.as(String.self) {
                                    Text(band).font(HindsightTheme.Typography.caption2)
                                }
                            }
                        }
                    }
                    .frame(height: 190)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Directional calibration chart")
                    .accessibilityValue(directional.map { "\($0.band.rawValue): n \($0.metric.eligibleCount), observed \(percent($0.metric.observedRate)), mean confidence \(percent($0.metric.meanConfidence))" }.joined(separator: "; "))
                }
            }
        }
    }

    private func confidenceBandRow(_ summary: ConfidenceBandSummary) -> some View {
        let metric = summary.metric
        return VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(summary.band.rawValue)
                    .font(HindsightTheme.Typography.headline)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Spacer()
                Text("n = \(metric.eligibleCount)")
                    .font(HindsightTheme.Typography.metadata)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }

            if metric.eligibleCount == 0 {
                Text("No resolved eligible forecasts in this range.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            } else {
                Text("Mean confidence \(percent(metric.meanConfidence)) · observed outcome \(percent(metric.observedRate)) · gap \(signedPoints(metric.signedGap))")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .monospacedDigit()
                Text(progressText(metric))
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            }
        }
        .padding(HindsightTheme.Spacing.md)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Gated cohorts

    private func cohortSection(snapshot: ForecastAnalyticsSnapshot) -> some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(
                title: "Context cohorts",
                subtitle: "Shown only when the analytics gate is met",
                systemImage: "square.grid.2x2"
            )

            cohortGroup(title: "By category", rows: snapshot.categoryCohorts.map { cohort in
                cohortRow(label: cohort.category.rawValue, metric: cohort.metric)
            }, eligibleCount: snapshot.overall.eligibleCount, required: "n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize) per category")

            cohortGroup(title: "By forecast horizon", rows: snapshot.horizonCohorts.map { cohort in
                cohortRow(label: cohort.horizon.rawValue, metric: cohort.metric)
            }, eligibleCount: snapshot.overall.eligibleCount, required: "n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize) per horizon")

            cohortGroup(title: "With or without reasoning", rows: snapshot.reasoningCohorts.map { cohort in
                cohortRow(label: cohort.hasReasoning ? "With Why" : "Without Why", metric: cohort.metric)
            }, eligibleCount: snapshot.overall.eligibleCount, required: "both groups need n ≥ \(ForecastAnalyticsSnapshot.cohortMinimumSampleSize)")
        }
    }

    private func cohortGroup(title: String, rows: [CohortDisplayRow], eligibleCount: Int, required: String) -> some View {
        HCard {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                Text(title)
                    .font(HindsightTheme.Typography.headline)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)

                if rows.isEmpty {
                    Text("Not shown yet. Current analytic base: n = \(eligibleCount); \(required).")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        .monospacedDigit()
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(rows) { row in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(row.label) · n = \(row.metric.eligibleCount)")
                                .font(HindsightTheme.Typography.subheadline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                                .monospacedDigit()
                            Text("Mean confidence \(percent(row.metric.meanConfidence)) · observed outcome \(percent(row.metric.observedRate)) · gap \(signedPoints(row.metric.signedGap)) · Brier \(brierText(row.metric.meanBrierScore))")
                                .font(HindsightTheme.Typography.caption)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                .monospacedDigit()
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    private func cohortRow(label: String, metric: ForecastMetricSummary) -> CohortDisplayRow {
        CohortDisplayRow(label: label, metric: metric)
    }

    // MARK: - Method and exclusions

    private func methodologySection(_ snapshot: ForecastAnalyticsSnapshot) -> some View {
        let exclusions = snapshot.exclusions
        return VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Method and exclusions", systemImage: "checklist")
            HCard(background: HindsightTheme.Colors.cardElevated) {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("\(snapshot.overall.eligibleCount) of \(exclusions.totalPredictions) stored forecasts are eligible for this record.")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .monospacedDigit()
                    Text("Eligible means a personal forecast whose check date has arrived, with valid 0–100% confidence and a terminal binary outcome: happened or did not happen.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    exclusionRow(label: "Sample forecasts", count: exclusions.sample)
                    exclusionRow(label: "Pending outcomes", count: exclusions.pending)
                    exclusionRow(label: "Partial or ambiguous outcomes", count: exclusions.partial)
                    exclusionRow(label: "Outcome recorded before check date", count: exclusions.notYetDue)
                    exclusionRow(label: "Invalid confidence", count: exclusions.invalidConfidence)
                    Text("Excluded total: \(exclusions.excludedCount). Brier score is the mean squared probability error; lower is better. This screen reports evidence, not a trait or a grade.")
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func exclusionRow(label: String, count: Int) -> some View {
        HStack {
            Text(label)
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
            Spacer()
            Text("n = \(count)")
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Navigation retained from the evidence ledger

    @ViewBuilder private var recentReviewsSection: some View {
        let reviewed = Statistics.reviewedDecisions(decisions)
            .filter { !SampleData.isDemoDecision($0) }
            .sorted { ($0.outcomeReview?.reviewedAt ?? .distantPast) > ($1.outcomeReview?.reviewedAt ?? .distantPast) }
            .prefix(4)
        if !reviewed.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Recent review record", subtitle: "Open the original decision and outcome", systemImage: "clock.arrow.circlepath")
                ForEach(Array(reviewed)) { decision in
                    NavigationLink(value: decision) {
                        HCard {
                            HStack(spacing: HindsightTheme.Spacing.sm) {
                                Image(systemName: decision.category.icon)
                                    .foregroundStyle(decision.category.color)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(decision.title)
                                        .font(HindsightTheme.Typography.callout)
                                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text(decision.outcomeReview?.reviewedAt.formatted(date: .abbreviated, time: .omitted) ?? "Reviewed")
                                        .font(HindsightTheme.Typography.caption)
                                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Evidence language

    private func overallStory(_ metric: ForecastMetricSummary) -> String {
        guard metric.eligibleCount > 0 else {
            return "No resolved personal forecast outcomes are eligible yet."
        }
        if metric.sampleState == .directional {
            return "Across \(metric.eligibleCount) resolved eligible forecasts, outcomes occurred \(percent(metric.observedRate)) of the time against mean stated confidence of \(percent(metric.meanConfidence))."
        }
        return "There are \(metric.eligibleCount) resolved eligible forecast\(metric.eligibleCount == 1 ? "" : "s") in the record. The measurements below are not yet a conclusion."
    }

    private func highConfidenceStory(_ metric: ForecastMetricSummary) -> String {
        guard metric.eligibleCount > 0 else {
            return "No resolved eligible 80%+ forecasts yet."
        }
        if metric.sampleState == .directional {
            return "In \(metric.eligibleCount) resolved 80%+ forecasts, \(gapInterpretation(metric.signedGap))."
        }
        return "\(metric.eligibleCount) resolved 80%+ forecast\(metric.eligibleCount == 1 ? "" : "s") recorded so far; keep resolving before drawing a conclusion."
    }

    private func sampleQualification(_ metric: ForecastMetricSummary) -> String {
        switch metric.sampleState {
        case .noEvidence:
            return "Resolve a forecast as happened or did not happen to begin the calibration record."
        case .learning:
            return "Learning state: n = \(metric.eligibleCount). Reach n = 5 for an early signal and n = 10 for a directional read."
        case .earlySignal:
            return "Early signal only: n = \(metric.eligibleCount). Reach n = 10 before treating the direction as a calibration read."
        case .directional:
            return "Directional read: n = \(metric.eligibleCount). The signed gap is \(signedPoints(metric.signedGap)); \(gapInterpretation(metric.signedGap))."
        }
    }

    private func progressText(_ metric: ForecastMetricSummary) -> String {
        switch metric.sampleState {
        case .noEvidence:
            return "n = 0 · no evidence yet"
        case .learning:
            return "n = \(metric.eligibleCount) / 5 for an early signal · n = \(metric.eligibleCount) / 10 for a directional read"
        case .earlySignal:
            return "n = \(metric.eligibleCount) / 10 for a directional read · early signal only"
        case .directional:
            return "n = \(metric.eligibleCount) · directional read"
        }
    }

    private func gapInterpretation(_ gap: Double) -> String {
        let points = Int((abs(gap) * 100).rounded())
        if points == 0 {
            return "observed outcomes and stated confidence matched in this sample"
        } else if gap < 0 {
            return "observed outcomes were \(points) percentage points below stated confidence (an over-confidence signal in this sample)"
        } else {
            return "observed outcomes were \(points) percentage points above stated confidence (an under-confidence signal in this sample)"
        }
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func signedPoints(_ value: Double) -> String {
        let points = Int((value * 100).rounded())
        return "\(points >= 0 ? "+" : "")\(points) pp"
    }

    private func brierText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return String(format: "%.3f", value)
    }

    private func countText(_ count: Int) -> String {
        "n = \(count)"
    }

    private func gapColor(_ gap: Double) -> Color {
        gap < 0 ? HindsightTheme.Colors.accent : HindsightTheme.Colors.success
    }

    private var metricColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        }
        return [
            GridItem(.flexible(), spacing: HindsightTheme.Spacing.sm),
            GridItem(.flexible(), spacing: HindsightTheme.Spacing.sm)
        ]
    }
}

private struct CohortDisplayRow: Identifiable {
    let label: String
    let metric: ForecastMetricSummary

    var id: String { label }
}

#Preview {
    InsightsView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
