//
//  TodayView.swift
//  Hindsight
//
//  Signal Garden home: a warm daily invitation, the fastest path to capture,
//  work that is ready to resolve, and one honest calibration pulse.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]

    @State private var showDuePredictionStack = false
    @State private var selectedDecision: Decision?
    @State private var animateSignal = false

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xl) {
                        if dynamicTypeSize.isAccessibilitySize {
                            // At large accessibility sizes, the primary action must remain
                            // immediately reachable instead of sitting beneath a tall insight card.
                            captureInvitation
                            welcomeHeader
                            calibrationPulse
                        } else {
                            welcomeHeader
                            calibrationPulse
                            captureInvitation
                        }

                        if personalDecisions.isEmpty {
                            emptyState
                        } else {
                            dueReviewsSection
                            upcomingForecastsSection
                        }

                        examplesSection
                    }
                    .padding(.horizontal, HindsightTheme.Spacing.md)
                    .padding(.top, HindsightTheme.Spacing.sm)
                    .padding(.bottom, HindsightTheme.Spacing.xxl + 24)
                    .hindsightReadableWidth()
                }
                .scrollIndicators(.hidden)
                .refreshable { try? await Task.sleep(nanoseconds: 250_000_000) }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedDecision) { DecisionDetailView(decision: $0) }
            .sheet(isPresented: $showDuePredictionStack) { DuePredictionResolveStackView() }
            .onAppear {
                openPendingRoutedDecision()
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 0.8)) { animateSignal = true }
            }
            .onChange(of: router.focusDecisionID) { _, _ in openPendingRoutedDecision() }
        }
        .hindsightBackground()
    }

    private var welcomeHeader: some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                Text("HINDSIGHT")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(1.1)
                    .foregroundStyle(HindsightTheme.Colors.accent)
                Text("What do you believe today?")
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            Spacer(minLength: 8)
            if !dynamicTypeSize.isAccessibilitySize {
                ZStack {
                    Circle()
                        .fill(HindsightTheme.Colors.accentGradient)
                    Image(systemName: "sparkle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 48, height: 48)
                .hindsightShadow(HindsightTheme.Shadows.glow)
                .accessibilityHidden(true)
            }
        }
    }

    private var calibrationPulse: some View {
        let metric = analytics.overall
        return HCard(padding: 0, background: HindsightTheme.Colors.card) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [
                        HindsightTheme.Colors.accent.opacity(0.20),
                        HindsightTheme.Colors.categoryPersonal.opacity(0.13),
                        HindsightTheme.Colors.success.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(HindsightTheme.Colors.amber.opacity(0.18))
                    .frame(width: 150, height: 150)
                    .offset(x: 44, y: -64)
                    .accessibilityHidden(true)

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                        signalOrb(metric: metric)
                        pulseCopy(metric)
                    }
                    .padding(HindsightTheme.Spacing.lg)
                } else {
                    HStack(spacing: HindsightTheme.Spacing.lg) {
                        signalOrb(metric: metric)
                        pulseCopy(metric)
                        Spacer(minLength: 0)
                    }
                    .padding(HindsightTheme.Spacing.lg)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Calibration pulse. \(pulseTitle(metric)). \(pulseDetail(metric))")
    }

    private func pulseCopy(_ metric: ForecastMetricSummary) -> some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
            Label("YOUR CALIBRATION PULSE", systemImage: "waveform.path.ecg")
                .font(HindsightTheme.Typography.metadata)
                .foregroundStyle(HindsightTheme.Colors.accent)
            Text(pulseTitle(metric))
                .font(HindsightTheme.Typography.title2)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(pulseDetail(metric))
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func signalOrb(metric: ForecastMetricSummary) -> some View {
        let progress = metric.eligibleCount == 0 ? 0 : min(1, Double(metric.eligibleCount) / 10)
        return ZStack {
            Circle()
                .stroke(HindsightTheme.Colors.surface.opacity(0.88), lineWidth: 10)
            Circle()
                .trim(from: 0, to: animateSignal ? max(0.02, progress) : 0.02)
                .stroke(
                    HindsightTheme.Colors.accentGradient,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Circle()
                .fill(HindsightTheme.Colors.surface.opacity(0.90))
                .padding(16)
            VStack(spacing: 0) {
                Text("\(metric.eligibleCount)")
                    .font(HindsightTheme.Typography.stat)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(metric.eligibleCount == 1 ? "result" : "results")
                    .font(HindsightTheme.Typography.caption2)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
        .frame(width: 102, height: 102)
        .accessibilityHidden(true)
    }

    private func pulseTitle(_ metric: ForecastMetricSummary) -> String {
        switch metric.sampleState {
        case .noEvidence:
            return "Your signal starts with one honest forecast."
        case .learning:
            return "Your pattern is beginning to glow."
        case .earlySignal, .directional:
            let points = Int((abs(metric.signedGap) * 100).rounded())
            if points < 5 { return "Your confidence and outcomes are close." }
            return metric.signedGap < 0
                ? "Confidence is \(points) points ahead of outcomes."
                : "Outcomes are \(points) points ahead of confidence."
        }
    }

    private func pulseDetail(_ metric: ForecastMetricSummary) -> String {
        switch metric.sampleState {
        case .noEvidence:
            return "Resolve predictions to reveal how well your certainty matches reality."
        case .learning:
            return "\(metric.eligibleCount) of 5 eligible outcomes recorded. Early percentages stay hidden until the sample is more useful."
        case .earlySignal:
            return "An early signal from \(metric.eligibleCount) resolved binary forecasts. Open Insights for the full context."
        case .directional:
            return "Based on \(metric.eligibleCount) resolved binary forecasts. Open Insights to explore confidence bands and patterns."
        }
    }

    private var captureInvitation: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                    Text("Capture a signal")
                        .font(HindsightTheme.Typography.title2)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("A belief, confidence, and check date.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            } else {
                HStack(spacing: HindsightTheme.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(HindsightTheme.Colors.accentGradient)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 42, height: 42)
                    .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Capture a signal")
                            .font(HindsightTheme.Typography.title2)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        Text("A belief, a confidence, and a date—usually under ten seconds.")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                }
            }

            Button {
                HapticsManager.shared.play(.medium)
                router.presentQuickCapture = true
            } label: {
                Label("Capture what I believe", systemImage: "sparkles")
                    .font(HindsightTheme.Typography.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(HindsightTheme.Colors.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.pill, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("Quick Capture")
            .accessibilityLabel("Quick Capture")
            .accessibilityHint("Record a forecast in one sheet")

            Button {
                router.presentNewDecision = true
            } label: {
                Label("Add detail", systemImage: "slider.horizontal.3")
                    .font(HindsightTheme.Typography.callout)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(HindsightTheme.Colors.accent)
            .accessibilityHint("Add options, effort, risk, and multiple forecasts")
        }
        .padding(HindsightTheme.Spacing.lg)
        .background(HindsightTheme.Colors.card, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.xl, style: .continuous)
                .stroke(HindsightTheme.Colors.accent.opacity(0.18), lineWidth: 1)
        }
        .hindsightShadow(HindsightTheme.Shadows.raised)
    }

    private var emptyState: some View {
        HCard(background: HindsightTheme.Colors.cardElevated) {
            HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(HindsightTheme.Colors.success)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                    Text("A clearer picture starts here")
                        .font(HindsightTheme.Typography.headline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Your first few forecasts create the raw material for personal insights. Nothing is scored until reality can actually be checked.")
                        .font(HindsightTheme.Typography.callout)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
        }
    }

    @ViewBuilder private var dueReviewsSection: some View {
        if !dueDecisions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                sectionHeading("Ready for reality", detail: "Close the loop while the outcome is fresh", icon: "sun.max.fill", color: HindsightTheme.Colors.amber)
                if duePendingPredictionCount > 0 {
                    Button { showDuePredictionStack = true } label: {
                        HStack(spacing: HindsightTheme.Spacing.md) {
                            ZStack {
                                Circle().fill(.white.opacity(0.20))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .frame(width: 42, height: 42)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Resolve \(duePendingPredictionCount) forecast\(duePendingPredictionCount == 1 ? "" : "s")")
                                    .font(HindsightTheme.Typography.headline)
                                Text("See what reality says")
                                    .font(HindsightTheme.Typography.caption)
                                    .opacity(0.86)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.body.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .padding(HindsightTheme.Spacing.md)
                        .background(
                            LinearGradient(
                                colors: [HindsightTheme.Colors.accent, HindsightTheme.Colors.amber],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Open the forecast resolution queue")
                }
                ForEach(dueDecisions) { decision in
                    decisionButton(decision, state: "Review due", accent: HindsightTheme.Colors.amber)
                }
            }
        }
    }

    @ViewBuilder private var upcomingForecastsSection: some View {
        if !upcomingDecisions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                sectionHeading("Growing signals", detail: "Waiting for their check date", icon: "leaf.fill", color: HindsightTheme.Colors.success)
                ForEach(Array(upcomingDecisions.prefix(5)).indices, id: \.self) { index in
                    let decision = Array(upcomingDecisions.prefix(5))[index]
                    decisionButton(
                        decision,
                        state: "Review \(decision.dueDate.formatted(.dateTime.month(.abbreviated).day()))",
                        accent: signalColors[index % signalColors.count]
                    )
                }
            }
        }
    }

    @ViewBuilder private var examplesSection: some View {
        if !exampleDecisions.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                sectionHeading("Try the garden", detail: "Examples stay separate from your records and insights", icon: "wand.and.stars", color: HindsightTheme.Colors.categoryPersonal)
                ForEach(Array(exampleDecisions.prefix(3)).indices, id: \.self) { index in
                    let decision = Array(exampleDecisions.prefix(3))[index]
                    decisionButton(decision, state: "Example only", accent: signalColors[index % signalColors.count])
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Examples, excluded from personal records and analytics")
        }
    }

    private func sectionHeading(_ title: String, detail: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.13), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HindsightTheme.Typography.title2)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(detail)
                    .font(HindsightTheme.Typography.footnote)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
    }

    private func decisionButton(_ decision: Decision, state: String, accent: Color) -> some View {
        Button { selectedDecision = decision } label: {
            HStack(spacing: HindsightTheme.Spacing.md) {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.pill, style: .continuous)
                    .fill(accent)
                    .frame(width: 6)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    HStack {
                        Text(state)
                            .font(HindsightTheme.Typography.caption2)
                            .foregroundStyle(accent)
                        Spacer()
                        Text("\(decision.averageConfidence)%")
                            .font(HindsightTheme.Typography.metadata)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .padding(.horizontal, 9)
                            .frame(minHeight: 28)
                            .background(accent.opacity(0.12), in: Capsule())
                    }
                    Text(decision.title)
                        .font(HindsightTheme.Typography.authoredStatement)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Captured \(decision.createdAt.formatted(.dateTime.month(.abbreviated).day().year()))")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.card, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .stroke(accent.opacity(0.16), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(state), \(decision.title), \(decision.averageConfidence) percent confidence")
    }

    private var analytics: ForecastAnalyticsSnapshot { Statistics.forecastAnalytics(personalDecisions) }
    private var signalColors: [Color] {
        [
            HindsightTheme.Colors.accent,
            HindsightTheme.Colors.categoryEducation,
            HindsightTheme.Colors.success,
            HindsightTheme.Colors.amber,
            HindsightTheme.Colors.categoryHealth
        ]
    }
    private var personalDecisions: [Decision] { decisions.filter { !SampleData.isDemoDecision($0) } }
    private var exampleDecisions: [Decision] { decisions.filter(SampleData.isDemoDecision) }
    private var dueDecisions: [Decision] {
        personalDecisions.filter {
            $0.status != .reviewed &&
            ($0.dueDate <= Date() || $0.predictions.contains { $0.status == .pending && $0.dueDate <= Date() })
        }
    }
    private var upcomingDecisions: [Decision] {
        personalDecisions
            .filter { decision in
                decision.status != .reviewed && !dueDecisions.contains(where: { $0.id == decision.id })
            }
            .sorted { $0.dueDate < $1.dueDate }
    }
    private var duePendingPredictionCount: Int {
        personalDecisions.flatMap(\.predictions).filter { $0.status == .pending && $0.dueDate <= Date() }.count
    }
    private func openPendingRoutedDecision() {
        guard let id = router.focusDecisionID,
              let decision = decisions.first(where: { $0.id == id }) else { return }
        selectedDecision = decision
        router.focusDecisionID = nil
    }
}

#Preview {
    TodayView()
        .environmentObject(AppRouter())
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
