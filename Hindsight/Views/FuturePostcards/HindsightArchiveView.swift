//
//  HindsightArchiveView.swift
//  Hindsight
//
//  A chronological evidence ledger for resolved personal records.
//

import SwiftUI
import SwiftData

struct HindsightArchiveView: View {
    private enum LedgerFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case happened = "Happened"
        case didNotHappen = "Did not happen"
        case ambiguous = "Ambiguous"
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
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                            header
                            filterControl
                            if filteredEntries.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                                    .padding(.vertical, HindsightTheme.Spacing.xl)
                            } else {
                                Text("\(filteredEntries.count) resolved forecast\(filteredEntries.count == 1 ? "" : "s")")
                                    .font(HindsightTheme.Typography.footnote)
                                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                ForEach(filteredEntries) { entry in
                                    Button { selectedDecision = entry.decision } label: { EvidenceLedgerRow(entry: entry) }
                                        .buttonStyle(.plain)
                                }
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
            .searchable(text: $searchText, prompt: "Search personal records")
            .navigationDestination(item: $selectedDecision) { DecisionDetailView(decision: $0) }
        }
        .hindsightBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
            Text("EVIDENCE LEDGER").font(HindsightTheme.Typography.metadata).tracking(0.8).foregroundStyle(HindsightTheme.Colors.steel)
            Text("What you expected, and what happened.").font(HindsightTheme.Typography.editorialDisplay).foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text("Resolved personal records only. Original forecasts remain alongside their later outcomes.")
                .font(HindsightTheme.Typography.callout).foregroundStyle(HindsightTheme.Colors.textSecondary)
        }
    }

    @ViewBuilder private var filterControl: some View {
        if dynamicTypeSize.isAccessibilitySize {
            HStack {
                Text("Outcome")
                    .font(HindsightTheme.Typography.subheadline)
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

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No resolved personal records", systemImage: "text.book.closed")
        } description: {
            Text("When you resolve a forecast, its before-and-after evidence will appear here. Examples do not appear in this ledger.")
        }
        .foregroundStyle(HindsightTheme.Colors.textSecondary)
    }

    @ViewBuilder private var examplesNotice: some View {
        if decisions.contains(where: SampleData.isDemoDecision) {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.xs) {
                Text("EXAMPLES ARE SEPARATE").font(HindsightTheme.Typography.metadata).foregroundStyle(HindsightTheme.Colors.amber)
                Text("Example records are not included in this personal history or its count. You can inspect or remove them in Settings.")
                    .font(HindsightTheme.Typography.footnote).foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            .padding(.top, HindsightTheme.Spacing.md)
        }
    }

    private var resolvedEntries: [EvidenceLedgerEntry] {
        decisions
            .filter { !SampleData.isDemoDecision($0) }
            .flatMap { decision -> [EvidenceLedgerEntry] in
                let resolved = decision.predictions.filter { $0.status != .pending }
                if resolved.isEmpty {
                    return decision.status == .reviewed && decision.outcomeReview != nil
                        ? [EvidenceLedgerEntry(decision: decision, prediction: nil)]
                        : []
                }
                return resolved.map { EvidenceLedgerEntry(decision: decision, prediction: $0) }
            }
            .sorted { $0.evidenceDate > $1.evidenceDate }
    }

    private var filteredEntries: [EvidenceLedgerEntry] {
        resolvedEntries.filter { entry in
            matchesSearch(entry) && matchesFilter(entry)
        }
    }

    private func matchesSearch(_ entry: EvidenceLedgerEntry) -> Bool {
        guard !searchText.isEmpty else { return true }
        let decision = entry.decision
        let review = decision.outcomeReview
        return [decision.title, decision.notes, entry.prediction?.title ?? "", entry.prediction?.actualResult ?? "",
                review?.whatHappened ?? "", review?.mainLesson ?? "", review?.whatSurprised ?? ""]
            .contains { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private func matchesFilter(_ entry: EvidenceLedgerEntry) -> Bool {
        switch filter {
        case .all: return true
        case .happened: return entry.prediction?.status == .correct
        case .didNotHappen: return entry.prediction?.status == .incorrect
        case .ambiguous: return entry.prediction == nil || entry.prediction?.status == .partial
        }
    }
}

private struct EvidenceLedgerEntry: Identifiable {
    let decision: Decision
    let prediction: Prediction?

    var id: UUID { prediction?.id ?? decision.id }
    var evidenceDate: Date { decision.outcomeReview?.reviewedAt ?? prediction?.dueDate ?? decision.dueDate }
}

private struct EvidenceLedgerRow: View {
    let entry: EvidenceLedgerEntry

    private var decision: Decision { entry.decision }

    var body: some View {
        VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(outcomeLabel.uppercased()).font(HindsightTheme.Typography.metadata).foregroundStyle(outcomeColor)
                Spacer()
                Text("CHECK DATE \(entry.evidenceDate.formatted(.dateTime.month(.abbreviated).day().year()))").font(HindsightTheme.Typography.metadata).foregroundStyle(HindsightTheme.Colors.textSecondary)
            }
            Text(forecastText).font(HindsightTheme.Typography.authoredStatement).foregroundStyle(HindsightTheme.Colors.textPrimary).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
            Divider().overlay(HindsightTheme.Colors.border)
            evidenceLine(label: "DECISION RECORD", text: decision.title)
            if let prediction = entry.prediction {
                evidenceLine(label: "STATED CONFIDENCE", text: "\(prediction.probabilityPercent)%")
            }
            evidenceLine(label: "OUTCOME", text: outcomeText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.card, in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous).stroke(HindsightTheme.Colors.border, lineWidth: 1) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(outcomeLabel), \(decision.title), forecast: \(forecastText), outcome: \(outcomeText)")
    }

    private func evidenceLine(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(HindsightTheme.Typography.metadata).foregroundStyle(HindsightTheme.Colors.steel)
            Text(text).font(HindsightTheme.Typography.callout).foregroundStyle(HindsightTheme.Colors.textSecondary).fixedSize(horizontal: false, vertical: true)
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
    private var outcomeLabel: String {
        entry.prediction?.status.eventOutcomeLabel ?? "Outcome recorded"
    }
    private var outcomeColor: Color {
        entry.prediction?.status.color ?? HindsightTheme.Colors.steel
    }
}

#Preview {
    HindsightArchiveView().modelContainer(SampleData.previewContainer)
}
