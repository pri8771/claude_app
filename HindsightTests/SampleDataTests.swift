//
//  SampleDataTests.swift
//  HindsightTests
//
//  Covers the demo-data contract from Docs/TEST_PLAN.md: insertion is
//  idempotent, demo data coexists with real user decisions, and removal
//  targets only stable-ID demo records — never the user's own, even if
//  the user's title happens to match a demo title.
//

import XCTest
import SwiftData
@testable import Hindsight

@MainActor
final class SampleDataTests: XCTestCase {

    private var storeDirectory: URL!

    /// Keeps every `ModelContainer` created by a test alive for that test's
    /// duration. SwiftData does not keep a store usable once its
    /// `ModelContainer` is deallocated: a helper that builds a container and
    /// returns only `container.mainContext` lets the container fall out of
    /// scope on return, leaving the caller holding a context backed by an
    /// already-torn-down store (fetches on it crash rather than throw).
    /// Each test method gets a fresh instance of this class, so there is
    /// nothing to reset between tests.
    private var retainedContainers: [ModelContainer] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HindsightSampleDataTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        retainedContainers.removeAll()
        if let storeDirectory {
            try? FileManager.default.removeItem(at: storeDirectory)
        }
        try super.tearDownWithError()
    }

    /// A fresh, isolated context per call.
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        let storeURL = storeDirectory.appendingPathComponent("\(UUID().uuidString).store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(for: schema, configurations: [config])
        retainedContainers.append(container)
        return container.mainContext
    }

    // MARK: Insertion idempotency

    func testInsertIfMissingOnlyInsertsOnce() throws {
        let context = try makeContext()

        let firstInsert = SampleData.insertIfMissing(into: context)
        XCTAssertTrue(firstInsert)
        let countAfterFirst = try context.fetchCount(FetchDescriptor<Decision>())
        XCTAssertEqual(countAfterFirst, 4)

        let secondInsert = SampleData.insertIfMissing(into: context)
        XCTAssertFalse(secondInsert, "A second call should be a no-op once demo data is present")
        let countAfterSecond = try context.fetchCount(FetchDescriptor<Decision>())
        XCTAssertEqual(countAfterSecond, countAfterFirst, "No duplicate demo decisions should be created")
    }

    func testInsertIfMissingCoexistsWithRealUserDecisions() throws {
        let context = try makeContext()
        let real = Decision(title: "My real decision, nothing to do with the demo")
        context.insert(real)
        try context.save()

        let inserted = SampleData.insertIfMissing(into: context)
        XCTAssertTrue(inserted)

        let all = try context.fetch(FetchDescriptor<Decision>())
        XCTAssertEqual(all.count, 5, "Demo data should be added alongside the existing real decision")
        XCTAssertTrue(all.contains { $0.title == "My real decision, nothing to do with the demo" })
    }

    func testContainsDemoDataReflectsCurrentState() throws {
        let context = try makeContext()
        XCTAssertFalse(SampleData.containsDemoData(in: context))

        SampleData.insertIfMissing(into: context)
        XCTAssertTrue(SampleData.containsDemoData(in: context))
    }

    // MARK: UUID-based identification

    func testIsDemoDecisionUsesStableIDsNotTitles() {
        let titleMatch = Decision(title: "Accept the offer at Northwind")
        // Deliberately does NOT set one of the stable demo IDs.
        // Even though the title matches a demo title, it should NOT be recognized as demo.
        XCTAssertFalse(SampleData.isDemoDecision(titleMatch),
                       "Title matching alone should not identify a decision as demo")

        let unrelated = Decision(title: "Accept the offer at Northwind, but different")
        XCTAssertFalse(SampleData.isDemoDecision(unrelated))
    }

    func testIsDemoDecisionRecognizesStableIDsRegardlessOfTitle() throws {
        let context = try makeContext()
        SampleData.insertIfMissing(into: context)
        let demoDecisions = try context.fetch(FetchDescriptor<Decision>())

        // Renaming a demo decision (as a user might) shouldn't hide it from
        // demo-data bookkeeping, since it's still identified by stable ID.
        let renamed = try XCTUnwrap(demoDecisions.first)
        renamed.title = "Something the user typed over the demo title"
        XCTAssertTrue(SampleData.isDemoDecision(renamed))
    }

    // MARK: Targeted deletion

    func testRemoveDeletesOnlyDemoDecisionsAndPreservesUserRecords() throws {
        let context = try makeContext()
        let real = Decision(title: "My real decision")
        context.insert(real)
        try context.save()
        SampleData.insertIfMissing(into: context)

        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 5)

        let removalResult = SampleData.remove(from: context)
        XCTAssertEqual(removalResult, .success(removedCount: 4))

        let remaining = try context.fetch(FetchDescriptor<Decision>())
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.title, "My real decision")
        XCTAssertFalse(SampleData.containsDemoData(in: context))
    }

    func testRemoveDoesNotDeleteTitleMatchedNonDemoRecords() throws {
        let context = try makeContext()
        // A user decision with a title that matches a demo title,
        // but without a stable demo UUID.
        let userWithDemoTitle = Decision(title: "Should I start a small side project?")
        context.insert(userWithDemoTitle)
        try context.save()

        let removalResult = SampleData.remove(from: context)
        // No demo data was inserted, so nothing should be removed.
        XCTAssertEqual(removalResult, .success(removedCount: 0))
        // The user's decision should survive, despite the title match.
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 1)
    }

    func testRemoveOnEmptyStoreIsANoOp() throws {
        let context = try makeContext()
        XCTAssertEqual(SampleData.remove(from: context), .success(removedCount: 0))
    }

    func testFailedSampleRemovalCanRetryWithoutTouchingMatchingPersonalRecord() throws {
        let context = try makeContext()
        defer { PersistenceService.shared = ContextPersister() }
        SampleData.insert(into: context)
        let sample = try XCTUnwrap(
            try context.fetch(FetchDescriptor<Decision>()).first(where: SampleData.isDemoDecision)
        )
        let personal = Decision(title: sample.title, notes: "Personal evidence")
        context.insert(personal)
        try context.save()

        PersistenceService.shared = SampleRemovalFailingPersister()
        XCTAssertEqual(SampleData.remove(from: context), .failed)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 5)

        PersistenceService.shared = ContextPersister()
        XCTAssertEqual(SampleData.remove(from: context), .success(removedCount: 4))

        let remaining = try context.fetch(FetchDescriptor<Decision>())
        XCTAssertEqual(remaining.map(\.id), [personal.id])
        XCTAssertEqual(remaining.first?.notes, "Personal evidence")
    }

    func testFirstSampleSaveFailureLeavesCallerContextUntouchedAndCanRetry() throws {
        let context = try makeContext()
        let originalPersister = PersistenceService.shared
        defer { PersistenceService.shared = originalPersister }

        PersistenceService.shared = SampleRemovalFailingPersister()
        XCTAssertFalse(SampleData.insert(into: context))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
        XCTAssertFalse(SampleData.containsDemoData(in: context))

        PersistenceService.shared = ContextPersister()
        XCTAssertTrue(SampleData.insert(into: context))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 4)
    }

    // MARK: insertIfEmpty compatibility path

    func testInsertIfEmptyOnlyInsertsIntoAnEmptyStore() throws {
        let context = try makeContext()
        XCTAssertTrue(SampleData.insertIfEmpty(into: context))
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 4)

        let real = Decision(title: "A user decision added after demo data")
        context.insert(real)
        try context.save()

        XCTAssertFalse(SampleData.insertIfEmpty(into: context), "Store is no longer empty")
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 5)
    }
}

private struct SampleRemovalFailingPersister: Persisting {
    func save(_ context: ModelContext) throws {
        throw NSError(domain: "SampleDataTests", code: 1)
    }
}
