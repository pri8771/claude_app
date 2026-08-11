//
//  HindsightArchiveView.swift
//  Hindsight
//
//  A colorful, chronological before-and-after trail for resolved personal
//  forecasts. Example records remain excluded at the selector boundary.
//

import SwiftUI
import SwiftData

struct HindsightArchiveView: View {
    private enum LedgerFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case happened = "Happened"
        case didNotHappen = "Did not happen"
        case ambiguous = "Could not judge"
        var id: String { rawValue }
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @State private var searchText = ""
    @State private var filter: LedgerFilter = .all
    @State private var selectedDecision: Decision?

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.background.ignoresSafeArea()

                if resolvedEntries.isEmpty {
                    historyEmptyState
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                            historyHero
                            outcomeSummary
                            filterControl

                            if filteredEntries.isEmpty {
                                filteredEmptyState
                            } else {
                                timeline
                                    .accessibilityIdentifier("history.timeline")
                            }

                            examplesNotice
                        }
                        .padding(HindsightTheme.Spacing.md)
                        .padding(.bottom, HindsightTheme.Spacing.xl)
                        .hindsightReadableWidth()
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search your evidence")
            .navigationDestination(item: $selectedDecision) { DecisionDetailView(decision: $0) }
        }
        .hindsightBackground()
    }

    // MARK: - Hero and filters

    private var historyHero: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            HStack(spacing: 7) {
                ForEach(Array(historyPalette.enumerated()), id: \.offset) { _, color in
                    Circle().fill(color).frame(width: 9, height: 9)
                }
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                Text("YOUR EVIDENCE TRAIL")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(0.9)
                    .foregroundStyle(HindsightTheme.Colors.categoryPersonal)
                Text("See the belief. Then see what reality returned.")
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Every card keeps your original forecast, stated confidence, and later outcome together. Examples never enter this trail.")
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(HindsightTheme.Spacing.lg)
        .background(HindsightTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .stroke(HindsightTheme.Colors.categoryPersonal.opacity(0.28), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("history.hero")
    }

    private var outcomeSummary: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: HindsightTheme.Spacing.sm) { outcomeSummaryTiles }
            VStack(spacing: HindsightTheme.Spacing.sm) { outcomeSummaryTiles }
        }
        .accessibilityIdentifier("history.outcomeSummary")
    }

    @ViewBuilder private var outcomeSummaryTiles: some View {
        HistoryCountTile(
            count: resolvedEntries.count,
            label: "Resolved",
            icon: "checkmark.seal",
            color: HindsightTheme.Colors.categoryPersonal
        )
        HistoryCountTile(
            count: resolvedEntries.filter { $0.prediction?.status == .correct }.count,
            label: "Happened",
            icon: "checkmark.circle.fill",
            color: HindsightTheme.Colors.success
        )
        HistoryCountTile(
            count: resolvedEntries.filter { $0.prediction?.status == .incorrect }.count,
            label: "Did not",
            icon: "xmark.circle.fill",
            color: HindsightTheme.Colors.accent
        )
        HistoryCountTile(
            count: resolvedEntries.filter { $0.prediction == nil || $0.prediction?.status == .partial }.count,
            label: "Unclear",
            icon: "circle.lefthalf.filled",
            color: HindsightTheme.Colors.amber
        )
    }

    @ViewBuilder private var filterControl: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
            HStack {
                Text("SHOW")
                    .font(HindsightTheme.Typography.metadata)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                Spacer()
                Text("\(filteredEntries.count) of \(resolvedEntries.count)")
                    .font(HindsightTheme.Typography.metadata)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }

            if dynamicTypeSize.isAccessibilitySize {
                HStack {
                    Text("Outcome")
                        .font(HindsightTheme.Typography.subheadline)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Spacer()
                    Picker("Outcome filter", selection: $filter) {
                        ForEach(LedgerFilter.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)
                }
                .frame(minHeight: 44)
            } else {
                Picker("Outcome filter", selection: $filter) {
                    ForEach(LedgerFilter.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
        .accessibilityIdentifier("history.outcomeFilter")
    }

    // MARK: - Timeline

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("CHRONOLOGICAL TRAIL")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(0.7)
                    .foregroundStyle(HindsightTheme.Colors.steel)
                Spacer()
                Text("Newest first")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            .padding(.bottom, HindsightTheme.Spacing.md)

            ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, entry in
                Button { selectedDecision = entry.decision } label: {
                    EvidenceTimelineRow(entry: entry, isLast: index == filteredEntries.count - 1)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("history.entry.\(entry.id.uuidString)")
            }
        }
    }

    // MARK: - States and source selection

    private var historyEmptyState: some View {
        VStack(spacing: HindsightTheme.Spacing.lg) {
            ZStack {
                ForEach(Array(historyPalette.enumerated()), id: \.offset) { index, color in
                    Circle()
                        .stroke(color.opacity(0.75), lineWidth: 3)
                        .frame(width: CGFloat(54 + index * 20), height: CGFloat(54 + index * 20))
                }
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(HindsightTheme.Colors.categoryPersonal)
            }
            .frame(width: 140, height: 140)
            VStack(spacing: HindsightTheme.Spacing.sm) {
                Text("Your before-and-after trail is waiting")
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Resolve a personal forecast and its original belief will appear beside what happened. Example records stay separate.")
                    .font(HindsightTheme.Typography.callout)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HindsightTheme.Spacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("history.empty")
    }

    private var filteredEmptyState: some View {
        VStack(spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: searchText.isEmpty ? "line.3.horizontal.decrease.circle" : "magnifyingglass")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(HindsightTheme.Colors.steel)
            Text(searchText.isEmpty ? "No outcomes match this filter" : "No evidence matches “\(searchText)”")
                .font(HindsightTheme.Typography.headline)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text("Your full resolved history is unchanged.")
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HindsightTheme.Spacing.xl)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var examplesNotice: some View {
        if decisions.contains(where: SampleData.isDemoDecision) {
            HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(HindsightTheme.Colors.amber)
                VStack(alignment: .leading, spacing: 3) {
                    Text("EXAMPLES STAY SEPARATE")
                        .font(HindsightTheme.Typography.metadata)
                        .foregroundStyle(HindsightTheme.Colors.amber)
                    Text("Example records are excluded from this timeline and every count above. Inspect or remove them in Settings.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                }
            }
            .padding(HindsightTheme.Spacing.md)
            .background(HindsightTheme.Colors.amber.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
            .accessibilityElement(children: .combine)
        }
    }

    private var resolvedEntries: [EvidenceTimelineEntry] {
        decisions
            .filter { !SampleData.isDemoDecision($0) }
            .flatMap { decision -> [EvidenceTimelineEntry] in
                let resolved = decision.predictions.filter { $0.status != .pending }
                if resolved.isEmpty {
                    return decision.status == .reviewed && decision.outcomeReview != nil
                        ? [EvidenceTimelineEntry(decision: decision, prediction: nil)]
                        : []
                }
                return resolved.map { EvidenceTimelineEntry(decision: decision, prediction: $0) }
            }
            .sorted { $0.evidenceDate > $1.evidenceDate }
    }

    private var filteredEntries: [EvidenceTimelineEntry] {
        resolvedEntries.filter { entry in
            matchesSearch(entry) && matchesFilter(entry)
        }
    }

    private func matchesSearch(_ entry: EvidenceTimelineEntry) -> Bool {
        guard !searchText.isEmpty else { return true }
        let decision = entry.decision
        let review = decision.outcomeReview
        return [
            decision.title,
            decision.notes,
            entry.prediction?.title ?? "",
            entry.prediction?.actualResult ?? "",
            review?.whatHappened ?? "",
            review?.mainLesson ?? "",
            review?.whatSurprised ?? ""
        ]
        .contains { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private func matchesFilter(_ entry: EvidenceTimelineEntry) -> Bool {
        switch filter {
        case .all: return true
        case .happened: return entry.prediction?.status == .correct
        case .didNotHappen: return entry.prediction?.status == .incorrect
        case .ambiguous: return entry.prediction == nil || entry.prediction?.status == .partial
        }
    }

    private var historyPalette: [Color] {
        [
            HindsightTheme.Colors.categoryPersonal,
            HindsightTheme.Colors.success,
            HindsightTheme.Colors.amber,
            HindsightTheme.Colors.accent
        ]
    }
}

private struct EvidenceTimelineEntry: Identifiable {
    let decision: Decision
    let prediction: Prediction?

    var id: UUID { prediction?.id ?? decision.id }
    var evidenceDate: Date { decision.outcomeReview?.reviewedAt ?? prediction?.dueDate ?? decision.dueDate }
}

private struct HistoryCountTile: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.13), in: Circle())
            VStack(alignment: .leading, spacing: 0) {
                Text("\(count)")
                    .font(HindsightTheme.Typography.title2)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                Text(label)
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
        .padding(.horizontal, HindsightTheme.Spacing.sm)
        .background(color.opacity(0.075))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous)
                .stroke(color.opacity(0.22), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct EvidenceTimelineRow: View {
    let entry: EvidenceTimelineEntry
    let isLast: Bool

    private var decision: Decision { entry.decision }
    private var color: Color { entry.prediction?.status.color ?? HindsightTheme.Colors.steel }

    var body: some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.sm) {
            timelineRail
            evidenceCard
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var timelineRail: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(color.opacity(0.15))
                Image(systemName: entry.prediction?.status.icon ?? "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(color)
            }
            .frame(width: 34, height: 34)
            if !isLast {
                Rectangle()
                    .fill(color.opacity(0.25))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 34)
        .accessibilityHidden(true)
    }

    private var evidenceCard: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: HindsightTheme.Spacing.sm) {
                Text(outcomeLabel.uppercased())
                    .font(HindsightTheme.Typography.metadata)
                    .foregroundStyle(color)
                Spacer()
                Text(entry.evidenceDate.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(HindsightTheme.Typography.metadata)
                    .monospacedDigit()
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
            }

            HStack(spacing: 6) {
                HBadge(text: decision.category.rawValue, icon: decision.category.icon, color: decision.category.color)
                if let confidence = entry.prediction?.probabilityPercent {
                    HBadge(text: "\(confidence)% stated", icon: "scope", color: HindsightTheme.Colors.steel)
                }
            }

            storyBlock(label: "BEFORE", text: forecastText, color: HindsightTheme.Colors.textPrimary, authored: true)

            HStack(spacing: 6) {
                Rectangle().fill(color.opacity(0.35)).frame(height: 1)
                Image(systemName: "arrow.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(color)
                Rectangle().fill(color.opacity(0.35)).frame(height: 1)
            }
            .accessibilityHidden(true)

            storyBlock(label: "AFTER", text: outcomeText, color: HindsightTheme.Colors.textSecondary, authored: false)

            if !lessonText.isEmpty {
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(HindsightTheme.Colors.amber)
                    Text(lessonText)
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(HindsightTheme.Spacing.sm)
                .background(HindsightTheme.Colors.amber.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.sm, style: .continuous))
            }

            if forecastText != decision.title {
                Text("Decision: \(decision.title)")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HindsightTheme.Spacing.md)
        .background(color.opacity(0.065))
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous)
                .stroke(color.opacity(0.28), lineWidth: 1)
        }
        .padding(.bottom, isLast ? 0 : HindsightTheme.Spacing.lg)
    }

    private func storyBlock(label: String, text: String, color: Color, authored: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(HindsightTheme.Typography.metadata)
                .tracking(0.6)
                .foregroundStyle(self.color)
            Text(text)
                .font(authored ? HindsightTheme.Typography.authoredStatement : HindsightTheme.Typography.callout)
                .foregroundStyle(color)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var forecastText: String {
        entry.prediction?.title ?? decision.title
    }

    private var outcomeText: String {
        let predictionResult = entry.prediction?.actualResult?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !predictionResult.isEmpty { return predictionResult }
        let reviewResult = decision.outcomeReview?.whatHappened.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return reviewResult.isEmpty ? "No outcome note was added." : reviewResult
    }

    private var lessonText: String {
        decision.outcomeReview?.mainLesson.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var outcomeLabel: String {
        entry.prediction?.status.eventOutcomeLabel ?? "Outcome recorded"
    }

    private var accessibilitySummary: String {
        let confidence = entry.prediction.map { ", stated confidence \($0.probabilityPercent) percent" } ?? ""
        return "\(outcomeLabel)\(confidence). Before: \(forecastText). After: \(outcomeText). Evidence date \(entry.evidenceDate.formatted(date: .long, time: .omitted))."
    }
}

#Preview {
    HindsightArchiveView().modelContainer(SampleData.previewContainer)
}
