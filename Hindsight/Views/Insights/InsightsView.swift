//
//  InsightsView.swift
//  Hindsight
//
//  Statistics and self-discovered patterns: headline numbers, charts of
//  decisions by category and quality over time, prediction accuracy, and
//  pattern cards mined from the user's own history.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                if decisions.isEmpty {
                    HEmptyState(
                        icon: "chart.bar.xaxis",
                        title: "No insights yet",
                        message: "Capture and review a few decisions and your patterns will appear here."
                    )
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                            headlineStats
                            patternsSection
                            categoryChart
                            qualityChart
                            predictionAccuracySection
                            recentReviewsSection
                            Color.clear.frame(height: 24)
                        }
                        .padding(HindsightTheme.Spacing.md)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Insights")
        }
    }

    // MARK: Headline stats

    private var headlineStats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HindsightTheme.Spacing.sm) {
            HStatTile(value: "\(Statistics.totalDecisions(decisions))", label: "Total decisions",
                      tint: HindsightTheme.Colors.accent, icon: "tray.full.fill")
            HStatTile(value: "\(Statistics.reviewRate(decisions))%", label: "Review rate",
                      tint: HindsightTheme.Colors.amber, icon: "arrow.triangle.2.circlepath")
            HStatTile(value: qualityString(Statistics.averageDecisionQuality(decisions)), label: "Avg decision quality",
                      tint: Color(hex: "5B8DEF"), icon: "brain")
            HStatTile(value: qualityString(Statistics.averageOutcomeQuality(decisions)), label: "Avg outcome quality",
                      tint: HindsightTheme.Colors.success, icon: "flag.checkered")
        }
    }

    // MARK: Patterns

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "Patterns", subtitle: "What your history reveals",
                           systemImage: "sparkles")
            ForEach(Statistics.patterns(decisions)) { pattern in
                HCard {
                    HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .fill(HindsightTheme.Colors.accent.opacity(0.16)).frame(width: 42, height: 42)
                            Image(systemName: pattern.icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(HindsightTheme.Colors.accent)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(pattern.title)
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            Text(pattern.detail)
                                .font(HindsightTheme.Typography.footnote)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    // MARK: Category chart

    private var categoryChart: some View {
        let data = Statistics.decisionsByCategory(decisions)
        return VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
            HSectionHeader(title: "By Category", systemImage: "chart.bar.fill")
            HCard {
                Chart(data) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Category", item.category.rawValue)
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text("\(item.count)")
                            .font(HindsightTheme.Typography.caption2)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(HindsightTheme.Colors.border)
                        AxisValueLabel().foregroundStyle(HindsightTheme.Colors.textTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel().foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                }
                .frame(height: max(140, CGFloat(data.count) * 38))
            }
        }
    }

    // MARK: Quality over time

    @ViewBuilder private var qualityChart: some View {
        let points = Statistics.qualityOverTime(decisions)
        if points.count >= 2 {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Quality Over Time", subtitle: "Decision process vs outcome",
                               systemImage: "chart.line.uptrend.xyaxis")
                HCard {
                    Chart {
                        ForEach(points) { point in
                            LineMark(x: .value("Date", point.date),
                                     y: .value("Quality", point.decisionQuality),
                                     series: .value("Series", "Decision"))
                            .foregroundStyle(HindsightTheme.Colors.amber)
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)

                            LineMark(x: .value("Date", point.date),
                                     y: .value("Quality", point.outcomeQuality),
                                     series: .value("Series", "Outcome"))
                            .foregroundStyle(HindsightTheme.Colors.success)
                            .interpolationMethod(.catmullRom)
                            .symbol(.square)
                        }
                    }
                    .chartForegroundStyleScale([
                        "Decision": HindsightTheme.Colors.amber,
                        "Outcome": HindsightTheme.Colors.success
                    ])
                    .chartYScale(domain: 0...5)
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                            AxisGridLine().foregroundStyle(HindsightTheme.Colors.border)
                            AxisValueLabel().foregroundStyle(HindsightTheme.Colors.textTertiary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                                .foregroundStyle(HindsightTheme.Colors.textTertiary)
                        }
                    }
                    .chartLegend(position: .bottom)
                    .frame(height: 200)
                }
            }
        }
    }

    // MARK: Prediction accuracy

    @ViewBuilder private var predictionAccuracySection: some View {
        let resolved = decisions.flatMap { $0.predictions }.filter { $0.status != .pending }
        if !resolved.isEmpty {
            let counts = Statistics.predictionStatusCounts(decisions).filter { $0.count > 0 }
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Prediction Accuracy", systemImage: "scope")
                HCard {
                    HStack(spacing: HindsightTheme.Spacing.lg) {
                        HProgressRing(
                            progress: Statistics.predictionAccuracy(decisions),
                            lineWidth: 10, size: 96,
                            tint: HindsightTheme.Colors.success,
                            label: "\(Int(Statistics.predictionAccuracy(decisions) * 100))%",
                            caption: "hit rate"
                        )
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(counts) { item in
                                HStack(spacing: 8) {
                                    Circle().fill(item.status.color).frame(width: 9, height: 9)
                                    Text(item.status.rawValue)
                                        .font(HindsightTheme.Typography.footnote)
                                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                    Spacer()
                                    Text("\(item.count)")
                                        .font(HindsightTheme.Typography.subheadline)
                                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Recent reviews

    @ViewBuilder private var recentReviewsSection: some View {
        let reviewed = Statistics.reviewedDecisions(decisions)
            .sorted { ($0.outcomeReview?.reviewedAt ?? .distantPast) > ($1.outcomeReview?.reviewedAt ?? .distantPast) }
            .prefix(4)
        if !reviewed.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Recent Reviews", systemImage: "clock.arrow.circlepath")
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
                                        .lineLimit(1)
                                    if let lesson = decision.outcomeReview?.mainLesson, !lesson.isEmpty {
                                        Text(lesson)
                                            .font(HindsightTheme.Typography.caption)
                                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                HStarRating(value: decision.outcomeReview?.outcomeQuality ?? 0, size: 12)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticsManager.shared.selectionChanged()
                    })
                }
            }
            .navigationDestination(for: Decision.self) { DecisionDetailView(decision: $0) }
        }
    }

    // MARK: Helpers

    private func qualityString(_ value: Double) -> String {
        value == 0 ? "—" : String(format: "%.1f", value)
    }
}

#Preview {
    InsightsView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
