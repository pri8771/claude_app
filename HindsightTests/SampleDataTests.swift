//
//  SampleDataTests.swift
//  HindsightTests
//
//  Covers the demo-data contract from Docs/TEST_PLAN.md: insertion is
//  idempotent, demo data coexists with real user decisions, legacy
//  (pre-stable-ID) demo records are still recognized, and removal targets
//  only demo records — never the user's own.
//

import XCTest
import SwiftData

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

    // MARK: Legacy recognition

    func testIsDemoDecisionRecognizesLegacyTitlesWithoutStableIDs() {
        let legacy = Decision(title: "Accept the offer at Northwind")
        // Deliberately does NOT set one of the stable demo IDs, simulating a
        // sample decision created before stable IDs existed.
        XCTAssertTrue(SampleData.isDemoDecision(legacy))

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

        let removedCount = SampleData.remove(from: context)
        XCTAssertEqual(removedCount, 4)

        let remaining = try context.fetch(FetchDescriptor<Decision>())
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining.first?.title, "My real decision")
        XCTAssertFalse(SampleData.containsDemoData(in: context))
    }

    func testRemoveAlsoDeletesLegacyTitleMatchedRecords() throws {
        let context = try makeContext()
        // A legacy demo decision with no stable ID and no dependents.
        let legacy = Decision(title: "Should I start a small side project?")
        context.insert(legacy)
        try context.save()

        let removedCount = SampleData.remove(from: context)
        XCTAssertEqual(removedCount, 1)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Decision>()), 0)
    }

    func testRemoveOnEmptyStoreIsANoOp() throws {
        let context = try makeContext()
        XCTAssertEqual(SampleData.remove(from: context), 0)
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
