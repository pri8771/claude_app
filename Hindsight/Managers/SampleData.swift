//
//  SampleData.swift
//  Hindsight
//
//  Seed data used for SwiftUI previews and the optional "Load sample
//  data" button in Settings, so the app feels alive on first run.
//

import Foundation
import SwiftData

enum SampleData {

    enum RemovalResult: Equatable {
        case success(removedCount: Int)
        case failed
    }

    private static let decisionIDs: [UUID] = [
        UUID(uuidString: "A1F00100-0000-4000-8000-000000000001")!,
        UUID(uuidString: "A1F00100-0000-4000-8000-000000000002")!,
        UUID(uuidString: "A1F00100-0000-4000-8000-000000000003")!,
        UUID(uuidString: "A1F00100-0000-4000-8000-000000000004")!
    ]

    /// Inserts a handful of realistic decisions into the given context.
    @MainActor
    @discardableResult
    static func insert(into context: ModelContext) -> Bool {
        // Build and persist samples in a separate context. A persister can
        // reject the first save, and deleting an uncommitted cascade graph in
        // the caller's context to recover from that failure leaves its visible
        // objects in an invalid state. The caller sees new samples only after
        // the staged save succeeds.
        let stagingContext = ModelContext(context.container)
        for decision in makeSampleDecisions() {
            stagingContext.insert(decision)
        }

        return PersistenceService.saveOrReport(stagingContext)
    }

    @MainActor
    private static func makeSampleDecisions() -> [Decision] {
        let calendar = Calendar.current
        let now = Date()
        func days(_ n: Int) -> Date { calendar.date(byAdding: .day, value: n, to: now)! }

        // 1. A reviewed career win.
        let job = Decision(
            title: "Accept the offer at Northwind",
            notes: "Bigger comp and a staff title, but a riskier company and a longer commute.",
            category: .career,
            stakesLevel: .high,
            status: .reviewed,
            isReversible: false,
            clarityScore: 88,
            chosenOptionTitle: "Take the Northwind offer",
            createdAt: days(-120),
            decidedAt: days(-118),
            dueDate: days(-30)
        )
        job.id = decisionIDs[0]
        job.options = [
            DecisionOption(title: "Take the Northwind offer", upside: "30% raise, staff title, equity",
                           downside: "Early-stage risk, longer commute", effortLevel: 4, riskLevel: 4, gutFeeling: 4),
            DecisionOption(title: "Stay at current job", upside: "Stable, known team, short commute",
                           downside: "Stalled growth, lower pay", effortLevel: 1, riskLevel: 2, gutFeeling: 2)
        ]
        job.predictions = [
            Prediction(title: "I'll still be glad I switched in 90 days", probabilityPercent: 75,
                       dueDate: days(-30), status: .correct, actualResult: "Loved the new scope"),
            Prediction(title: "The commute will bother me", probabilityPercent: 60,
                       dueDate: days(-30), status: .incorrect, actualResult: "Went remote two days a week")
        ]
        job.outcomeReview = OutcomeReview(
            whatHappened: "Joined Northwind, shipped a major project in the first quarter and got real ownership.",
            outcomeQuality: 5, decisionQuality: 4, wouldDoAgain: true,
            whatSurprised: "The team was more supportive than the interviews suggested.",
            mainLesson: "Bet on scope and people over short-term stability.",
            reviewedAt: days(-28)
        )

        // 2. A financial decision awaiting review (past due → needs review).
        let move = Decision(
            title: "Move to a cheaper apartment across town",
            notes: "Saves $600/month but further from friends and the gym.",
            category: .financial,
            stakesLevel: .medium,
            status: .awaitingReview,
            isReversible: true,
            clarityScore: 64,
            chosenOptionTitle: "Move and bank the savings",
            createdAt: days(-50),
            decidedAt: days(-45),
            dueDate: days(-3)
        )
        move.id = decisionIDs[1]
        move.options = [
            DecisionOption(title: "Move and bank the savings", upside: "$600/mo saved", downside: "Longer trips to see friends",
                           effortLevel: 3, riskLevel: 2, gutFeeling: 3),
            DecisionOption(title: "Stay put", upside: "Convenient, social", downside: "Burning cash",
                           effortLevel: 1, riskLevel: 1, gutFeeling: 3)
        ]
        move.predictions = [
            Prediction(title: "I'll actually save the difference, not spend it", probabilityPercent: 55, dueDate: days(-3)),
            Prediction(title: "I'll see friends just as often", probabilityPercent: 40, dueDate: days(-3))
        ]

        // 3. A health decision awaiting review (future).
        let gym = Decision(
            title: "Commit to morning workouts for a quarter",
            notes: "Trade evening flexibility for consistent energy.",
            category: .health,
            stakesLevel: .low,
            status: .awaitingReview,
            isReversible: true,
            clarityScore: 52,
            chosenOptionTitle: "5am gym, 3x a week",
            createdAt: days(-10),
            decidedAt: days(-9),
            dueDate: days(20)
        )
        gym.id = decisionIDs[2]
        gym.options = [
            DecisionOption(title: "5am gym, 3x a week", upside: "Energy, routine", downside: "Earlier nights",
                           effortLevel: 4, riskLevel: 1, gutFeeling: 4)
        ]
        gym.predictions = [
            Prediction(title: "I'll stick with it for the full 12 weeks", probabilityPercent: 50, dueDate: days(20)),
            Prediction(title: "My energy in the afternoons will improve", probabilityPercent: 70, dueDate: days(20))
        ]

        // 4. An active decision still being weighed.
        let side = Decision(
            title: "Should I start a small side project?",
            notes: "A weekend app idea I keep coming back to.",
            category: .creative,
            stakesLevel: .low,
            status: .active,
            isReversible: true,
            clarityScore: 40,
            createdAt: days(-2),
            dueDate: days(45)
        )
        side.id = decisionIDs[3]
        side.options = [
            DecisionOption(title: "Build a tiny MVP", upside: "Learn, ship, fun", downside: "Less rest",
                           effortLevel: 4, riskLevel: 2, gutFeeling: 4),
            DecisionOption(title: "Park the idea", upside: "Rest, focus on work", downside: "Itch unscratched",
                           effortLevel: 1, riskLevel: 1, gutFeeling: 2)
        ]
        side.predictions = [
            Prediction(title: "I'll still be excited about it in a month", probabilityPercent: 65, dueDate: days(45))
        ]

        return [job, move, gym, side]
    }

    /// Inserts demo decisions if they are not already present. Demo data can
    /// safely coexist with real decisions and is identified by stable IDs.
    @MainActor
    @discardableResult
    static func insertIfMissing(into context: ModelContext) -> Bool {
        guard !containsDemoData(in: context) else { return false }
        return insert(into: context)
    }

    @MainActor
    static func containsDemoData(in context: ModelContext) -> Bool {
        let decisions = (try? context.fetch(FetchDescriptor<Decision>())) ?? []
        return decisions.contains { isDemoDecision($0) }
    }

    static func isDemoDecision(_ decision: Decision) -> Bool {
        decisionIDs.contains(decision.id)
    }

    /// Removes only records created by the demo-data feature, identified by
    /// stable demo UUIDs. Demo records are identified purely by provenance,
    /// not by heuristic title matching.
    @MainActor
    @discardableResult
    static func remove(from context: ModelContext) -> RemovalResult {
        let decisions = (try? context.fetch(FetchDescriptor<Decision>())) ?? []
        let demoDecisions = decisions.filter { isDemoDecision($0) }

        let demoIDs = Set(demoDecisions.map(\.id))
        guard persistDeletion(of: demoIDs, from: context) else {
            return .failed
        }

        // Do not delete the same cascade graph a second time in the caller's
        // context. SwiftData invalidates its child backing data as part of the
        // staged save; a redundant local cascade can then crash while reading
        // those invalidated children. @Query observes the store save directly.
        return .success(removedCount: demoDecisions.count)
    }

    /// Performs the durable part of a destructive change without touching the
    /// caller's managed objects. ModelContext.transaction is unavailable here:
    /// on iOS 17 it persists the transaction itself, which would bypass the
    /// injectable Persister and make a reported failure non-atomic.
    @MainActor
    private static func persistDeletion(of ids: Set<UUID>, from context: ModelContext) -> Bool {
        guard !ids.isEmpty else { return true }

        let stagingContext = ModelContext(context.container)
        guard let stagedDecisions = try? stagingContext.fetch(FetchDescriptor<Decision>()) else {
            return false
        }

        for decision in stagedDecisions where ids.contains(decision.id) {
            stagingContext.delete(decision)
        }
        return PersistenceService.saveOrReport(stagingContext)
    }

    /// Compatibility for existing call sites that want samples only in an
    /// otherwise empty store, such as previews.
    @MainActor
    @discardableResult
    static func insertIfEmpty(into context: ModelContext) -> Bool {
        let existing = (try? context.fetchCount(FetchDescriptor<Decision>())) ?? 0
        guard existing == 0 else { return false }
        return insertIfMissing(into: context)
    }

    /// Returns an in-memory model container pre-populated for previews.
    @MainActor
    static var previewContainer: ModelContainer = {
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        insert(into: container.mainContext)
        return container
    }()
}
