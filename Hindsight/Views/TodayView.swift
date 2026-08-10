//
//  TodayView.swift
//  Hindsight
//
//  The personal decision desk: due evidence, a fast forecast entry point,
//  upcoming commitments, and one carefully qualified signal.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]

    @State private var showDuePredictionStack = false
    @State private var selectedDecision: Decision?

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: HindsightTheme.Spacing.xl) {
                        header
                        recordForecastAction

                        if personalDecisions.isEmpty {
                            emptyState
                        } else {
                            dueReviewsSection
                            upcomingForecastsSection
                            analyticsSignal
                        }

                        examplesSection
                    }
                    .padding(.horizontal, HindsightTheme.Spacing.md)
                    .padding(.top, HindsightTheme.Spacing.md)
                    .padding(.bottom, HindsightTheme.Spacing.xxl)
                    .hindsightReadableWidth()
                }
                .scrollIndicators(.hidden)
                .refreshable { try? await Task.sleep(nanoseconds: 250_000_000) }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedDecision) { DecisionDetailView(decision: $0) }
            .sheet(isPresented: $showDuePredictionStack) { DuePredictionResolveStackView() }
            .onAppear(perform: openPendingRoutedDecision)
            .onChange(of: router.focusDecisionID) { _, _ in openPendingRoutedDecision() }
        }
        .hindsightBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
            Text("PRIVATE DECISION RECORD")
                .font(HindsightTheme.Typography.metadata)
                .tracking(0.8)
                .foregroundStyle(HindsightTheme.Colors.steel)
            Text("What needs an honest review?")
                .font(HindsightTheme.Typography.editorialDisplay)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
    }

    private var recordForecastAction: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            Text("Record a forecast")
                .font(HindsightTheme.Typography.title2)
            Text("State what you expect, choose a confidence, and set a date to check it against reality.")
                .font(HindsightTheme.Typography.callout)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
            Button {
                HapticsManager.shared.play(.medium)
                router.presentQuickCapture = true
            } label: {
                Label("Record forecast", systemImage: "plus")
                    .font(HindsightTheme.Typography.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(HindsightTheme.Colors.accent)
            .accessibilityIdentifier("Quick Capture")
            .accessibilityLabel("Quick Capture")
            .accessibilityHint("Record a forecast in one sheet")

            Button {
                router.presentNewDecision = true
            } label: {
                Label("Add detail", systemImage: "list.bullet.rectangle")
                    .font(HindsightTheme.Typography.callout)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(HindsightTheme.Colors.accent)
            .accessibilityHint("Add options, effort, risk, and multiple forecasts")
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.card, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous).stroke(HindsightTheme.Colors.border, lineWidth: 1) }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No personal records yet", systemImage: "scope")
        } description: {
            Text("Start with a claim you can later check against reality. Example records, if installed, remain separate below.")
        }
        .foregroundStyle(HindsightTheme.Colors.textSecondary)
    }

    @ViewBuilder private var dueReviewsSection: some View {
        if !dueDecisions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                sectionHeading("Due for outcome review", detail: "Records whose review date has arrived")
                if duePendingPredictionCount > 0 {
                    Button { showDuePredictionStack = true } label: {
                        Label("Resolve \(duePendingPredictionCount) forecast\(duePendingPredictionCount == 1 ? "" : "s")", systemImage: "checkmark.circle")
                            .font(HindsightTheme.Typography.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(HindsightTheme.Colors.accent)
                    .accessibilityHint("Open the forecast resolution queue")
                }
                ForEach(dueDecisions) { decision in
                    decisionButton(decision, state: "Review due", accent: HindsightTheme.Colors.accent)
                }
            }
        }
    }

    @ViewBuilder private var upcomingForecastsSection: some View {
        if !upcomingDecisions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                sectionHeading("Upcoming forecasts", detail: "Personal records waiting for their review date")
                ForEach(Array(upcomingDecisions.prefix(5))) { decision in
                    decisionButton(decision, state: "Review \(decision.dueDate.formatted(.dateTime.month(.abbreviated).day()))", accent: HindsightTheme.Colors.steel)
                }
            }
        }
    }

    @ViewBuilder private var analyticsSignal: some View {
        let metric = Statistics.forecastAnalytics(personalDecisions).overall
        if metric.eligibleCount >= 5 {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                sectionHeading("One signal", detail: "Resolved binary forecasts only")
                Text("Observed outcome rate: \(metric.observedRate, format: .percent.precision(.fractionLength(0)))")
                    .font(HindsightTheme.Typography.stat)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text("Across \(metric.eligibleCount) resolved personal forecast\(metric.eligibleCount == 1 ? "" : "s"); mean stated confidence was \(metric.meanConfidence, format: .percent.precision(.fractionLength(0))). Pending and ambiguous outcomes are excluded.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.cardElevated, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        } else if metric.eligibleCount > 0 {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                sectionHeading("Calibration is learning", detail: "Resolved binary forecasts only")
                Text("\(metric.eligibleCount) of 5 outcomes recorded")
                    .font(HindsightTheme.Typography.title2)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .monospacedDigit()
                Text("Resolve \(5 - metric.eligibleCount) more eligible forecast\(metric.eligibleCount == 4 ? "" : "s") for an early signal. Percentages this small are evidence in progress, not a conclusion.")
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.cardElevated, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        }
    }

    @ViewBuilder private var examplesSection: some View {
        if !exampleDecisions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                sectionHeading("Examples", detail: "Practice records — excluded from personal reviews and analytics")
                ForEach(Array(exampleDecisions.prefix(3))) { decision in
                    decisionButton(decision, state: "Example record", accent: HindsightTheme.Colors.amber)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Examples, excluded from personal records and analytics")
        }
    }

    private func sectionHeading(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(HindsightTheme.Typography.title2).foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text(detail).font(HindsightTheme.Typography.footnote).foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
    }

    private func decisionButton(_ decision: Decision, state: String, accent: Color) -> some View {
        Button { selectedDecision = decision } label: {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HStack {
                    Text(state.uppercased()).font(HindsightTheme.Typography.metadata).foregroundStyle(accent)
                    Spacer()
                    Text("\(decision.averageConfidence)%").font(HindsightTheme.Typography.metadata).foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
                Text(decision.title).font(HindsightTheme.Typography.authoredStatement).foregroundStyle(HindsightTheme.Colors.textPrimary).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                Text("Recorded \(decision.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                    .font(HindsightTheme.Typography.footnote).foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.card, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous).stroke(HindsightTheme.Colors.border, lineWidth: 1) }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(state), \(decision.title), \(decision.averageConfidence) percent confidence")
    }

    private var personalDecisions: [Decision] { decisions.filter { !SampleData.isDemoDecision($0) } }
    private var exampleDecisions: [Decision] { decisions.filter(SampleData.isDemoDecision) }
    private var dueDecisions: [Decision] {
        personalDecisions.filter { $0.status != .reviewed && ($0.dueDate <= Date() || $0.predictions.contains { $0.status == .pending && $0.dueDate <= Date() }) }
    }
    private var upcomingDecisions: [Decision] {
        personalDecisions.filter { decision in
            decision.status != .reviewed && !dueDecisions.contains(where: { $0.id == decision.id })
        }
            .sorted { $0.dueDate < $1.dueDate }
    }
    private var duePendingPredictionCount: Int {
        personalDecisions.flatMap(\.predictions).filter { $0.status == .pending && $0.dueDate <= Date() }.count
    }
    private func openPendingRoutedDecision() {
        guard let id = router.focusDecisionID, let decision = decisions.first(where: { $0.id == id }) else { return }
        selectedDecision = decision
        router.focusDecisionID = nil
    }
}

#Preview {
    TodayView().environmentObject(AppRouter()).environmentObject(NotificationManager.shared).modelContainer(SampleData.previewContainer)
}
