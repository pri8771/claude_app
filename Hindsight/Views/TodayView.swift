//
//  TodayView.swift
//  Hindsight
//
//  The home screen: a personal greeting, a stats strip, the decisions
//  that need attention, recent wins, and a floating button to capture a
//  new decision.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @AppStorage(AppStorageKeys.userName) private var userName = "there"

    @State private var showQuickCapture = false
    @State private var showNewDecision = false
    @State private var showDuePredictionStack = false
    @State private var selectedDecision: Decision?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                        header
                        statsStrip

                        if decisions.isEmpty {
                            VStack(spacing: HindsightTheme.Spacing.sm) {
                                HEmptyState(
                                    icon: "brain.head.profile",
                                    title: "Capture a prediction",
                                    message: "Record a thought now and revisit it when reality has more to say.",
                                    actionTitle: "Quick Capture",
                                    action: { showQuickCapture = true }
                                )
                                Button {
                                    showQuickCapture = false
                                    showNewDecision = true
                                } label: {
                                    Label("Add detail", systemImage: "list.bullet.rectangle")
                                        .font(HindsightTheme.Typography.subheadline)
                                }
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                                .accessibilityHint("Open the full decision wizard")
                            }
                            .padding(.top, HindsightTheme.Spacing.xl)
                        } else {
                            needsReviewSection
                            activeSection
                            recentWinsSection
                        }

                        Color.clear.frame(height: 90) // breathing room for FAB
                    }
                    .padding(.horizontal, HindsightTheme.Spacing.md)
                    .padding(.top, HindsightTheme.Spacing.sm)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    // SwiftData @Query updates automatically; this just gives
                    // the pull-to-refresh affordance a satisfying beat.
                    HapticsManager.shared.play(.soft)
                    try? await Task.sleep(nanoseconds: 350_000_000)
                }

                floatingAddButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { EmptyView() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showQuickCapture = false
                        showNewDecision = true
                    } label: {
                        Label("Add detail", systemImage: "list.bullet.rectangle")
                    }
                    .accessibilityHint("Open the full decision wizard")
                }
            }
            .navigationDestination(item: $selectedDecision) { DecisionDetailView(decision: $0) }
            .sheet(isPresented: $showQuickCapture) {
                QuickCaptureSheet()
            }
            .sheet(isPresented: $showNewDecision) {
                NewDecisionWizard()
            }
            .sheet(isPresented: $showDuePredictionStack) {
                DuePredictionResolveStackView()
            }
        }
    }

    // MARK: Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting + ",")
                .font(HindsightTheme.Typography.body)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
            Text(userName)
                .font(HindsightTheme.Typography.largeTitle)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(HindsightTheme.Typography.footnote)
                .foregroundStyle(HindsightTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, HindsightTheme.Spacing.sm)
    }

    private var statsStrip: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            HStatTile(value: "\(decisions.count)", label: "Decisions",
                      tint: HindsightTheme.Colors.accent, icon: "tray.full.fill")
            HStatTile(value: "\(pendingReviewCount)", label: "To review",
                      tint: HindsightTheme.Colors.amber, icon: "hourglass")
            HStatTile(value: "\(Statistics.averageConfidence(decisions))%", label: "Avg confidence",
                      tint: HindsightTheme.Colors.success, icon: "gauge.medium")
        }
    }

    @ViewBuilder private var needsReviewSection: some View {
        let items = decisions.filter { decision in
            decision.needsReview || decision.predictions.contains {
                $0.status == .pending && $0.dueDate <= Date()
            }
        }
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Ready to Revisit", subtitle: "A quick look back closes the loop",
                               systemImage: "exclamationmark.circle.fill", tint: HindsightTheme.Colors.accent)
                if duePendingPredictionCount > 0 {
                    HButton(
                        title: "Resolve \(duePendingPredictionCount) Prediction\(duePendingPredictionCount == 1 ? "" : "s")",
                        icon: "scope"
                    ) {
                        showDuePredictionStack = true
                    }
                    .accessibilityHint("Opens the fast prediction review stack")
                }
                ForEach(items) { decision in
                    Button { selectedDecision = decision } label: {
                        DecisionCardView(decision: decision, emphasiseReview: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var activeSection: some View {
        let items = decisions.filter { $0.status == .active || ($0.status == .awaitingReview && !$0.needsReview) }
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "In Progress", subtitle: "Decisions you're living through",
                               systemImage: "circle.dashed")
                ForEach(items) { decision in
                    Button { selectedDecision = decision } label: {
                        DecisionCardView(decision: decision)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var recentWinsSection: some View {
        let items = decisions
            .filter { $0.wasGoodOutcome }
            .sorted { ($0.outcomeReview?.reviewedAt ?? .distantPast) > ($1.outcomeReview?.reviewedAt ?? .distantPast) }
            .prefix(3)
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                HSectionHeader(title: "Recent Wins", subtitle: "Decisions that aged well",
                               systemImage: "trophy.fill", tint: HindsightTheme.Colors.success)
                ForEach(Array(items)) { decision in
                    Button { selectedDecision = decision } label: {
                        DecisionCardView(decision: decision)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var floatingAddButton: some View {
        Button {
            HapticsManager.shared.play(.medium)
            showQuickCapture = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(HindsightTheme.Colors.accentGradient)
                .clipShape(Circle())
                .hindsightShadow(HindsightTheme.Shadows.glow)
        }
        .padding(HindsightTheme.Spacing.lg)
        .accessibilityLabel("Quick Capture")
        .accessibilityHint("Capture a prediction in one sheet")
    }

    // MARK: Helpers

    private var pendingReviewCount: Int {
        decisions.filter { $0.needsReview }.count
    }

    private var duePendingPredictionCount: Int {
        decisions
            .flatMap { $0.predictions }
            .filter { $0.status == .pending && $0.dueDate <= Date() }
            .count
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Working late"
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
