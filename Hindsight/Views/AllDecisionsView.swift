//
//  AllDecisionsView.swift
//  Hindsight
//
//  A searchable, filterable list of every decision in the journal.
//

import SwiftUI
import SwiftData

struct AllDecisionsView: View {
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]

    @State private var searchText = ""
    @State private var categoryFilter: DecisionCategory?
    @State private var statusFilter: DecisionStatus?
    @State private var showNewDecision = false

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                if decisions.isEmpty {
                    HEmptyState(
                        icon: "books.vertical.fill",
                        title: "No decisions yet",
                        message: "Every decision you capture lands here, searchable forever.",
                        actionTitle: "New Decision",
                        action: { showNewDecision = true }
                    )
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: HindsightTheme.Spacing.md) {
                            filterBar

                            if filtered.isEmpty {
                                HEmptyState(icon: "magnifyingglass",
                                            title: "No matches",
                                            message: "Try a different search or clear your filters.")
                            } else {
                                ForEach(filtered) { decision in
                                    NavigationLink(value: decision) {
                                        DecisionCardView(decision: decision, emphasiseReview: decision.needsReview)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            Color.clear.frame(height: 24)
                        }
                        .padding(.horizontal, HindsightTheme.Spacing.md)
                        .padding(.top, HindsightTheme.Spacing.sm)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Decisions")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search decisions")
            .navigationDestination(for: Decision.self) { DecisionDetailView(decision: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNewDecision = true } label: { Image(systemName: "plus") }
                        .tint(HindsightTheme.Colors.accent)
                }
            }
            .sheet(isPresented: $showNewDecision) { NewDecisionWizard() }
        }
    }

    // MARK: Filter bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HindsightTheme.Spacing.sm) {
                Menu {
                    Button("All statuses") { statusFilter = nil }
                    ForEach(DecisionStatus.allCases) { status in
                        Button(status.rawValue) { statusFilter = status }
                    }
                } label: {
                    FilterChip(title: statusFilter?.rawValue ?? "Status",
                               icon: "line.3.horizontal.decrease.circle",
                               isActive: statusFilter != nil)
                }

                Menu {
                    Button("All categories") { categoryFilter = nil }
                    ForEach(DecisionCategory.allCases) { category in
                        Button { categoryFilter = category } label: {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                } label: {
                    FilterChip(title: categoryFilter?.rawValue ?? "Category",
                               icon: categoryFilter?.icon ?? "square.grid.2x2",
                               isActive: categoryFilter != nil)
                }

                if categoryFilter != nil || statusFilter != nil {
                    Button {
                        categoryFilter = nil; statusFilter = nil
                    } label: {
                        FilterChip(title: "Clear", icon: "xmark", isActive: false, tint: HindsightTheme.Colors.accent)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Filtering

    private var filtered: [Decision] {
        decisions.filter { decision in
            let matchesSearch = searchText.isEmpty
                || decision.title.localizedCaseInsensitiveContains(searchText)
                || decision.notes.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = categoryFilter == nil || decision.category == categoryFilter
            let matchesStatus = statusFilter == nil || decision.status == statusFilter
            return matchesSearch && matchesCategory && matchesStatus
        }
    }
}

// MARK: - Filter chip

private struct FilterChip: View {
    let title: String
    let icon: String
    var isActive: Bool
    var tint: Color = HindsightTheme.Colors.accent

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 12, weight: .semibold))
            Text(title).font(HindsightTheme.Typography.subheadline)
        }
        .foregroundStyle(isActive ? .white : HindsightTheme.Colors.textSecondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isActive ? tint : HindsightTheme.Colors.card)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(HindsightTheme.Colors.border, lineWidth: isActive ? 0 : 1))
    }
}

#Preview {
    AllDecisionsView()
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
