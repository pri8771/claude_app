//
//  DemoDataSafetyTests.swift
//  HindsightTests
//
//  Verifies the demo-data identity contract from T3: demo decisions are
//  identified by stable UUIDs only, not by title. A user-created decision
//  that happens to have the same title as a demo decision must survive
//  removal (PAIR_QA 11).
//

import XCTest
import SwiftData
@testable import Hindsight

@MainActor
final class DemoDataSafetyTests: XCTestCase {

    private var storeDirectory: URL!
    private var retainedContainers: [ModelContainer] = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HindsightDemoDataSafetyTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        retainedContainers.removeAll()
        if let storeDirectory {
            try? FileManager.default.removeItem(at: storeDirectory)
        }
        try super.tearDownWithError()
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        let storeURL = storeDirectory.appendingPathComponent("\(UUID().uuidString).store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        let container = try ModelContainer(for: schema, configurations: [config])
        retainedContainers.append(container)
        return container.mainContext
    }

    func testDemoCleanup_deletesOnlyExplicitDemoProvenance() throws {
        let context = try makeContext()

        // Insert demo data via SampleData.insert.
        SampleData.insert(into: context)

        // Create a user decision with a title that exactly matches a demo title,
        // but with its own random UUID (not in the stable demo IDs list).
        let userDecision = Decision(
            title: "Should I start a small side project?",  // Same as demo title
            notes: "This is MY decision, not the sample.",
            category: .creative,
            stakesLevel: .low,
            status: .active,
            isReversible: true,
            clarityScore: 40,
            createdAt: Date()
        )
        // Explicitly give it a random UUID to ensure it's not in the demo IDs.
        userDecision.id = UUID()

        context.insert(userDecision)
        try context.save()

        // Verify we have 5 decisions: 4 demo + 1 user.
        let countBefore = try context.fetchCount(FetchDescriptor<Decision>())
        XCTAssertEqual(countBefore, 5)

        // Remove demo data.
        let removedCount = SampleData.remove(from: context)

        // Only the 4 demo decisions should be removed (by stable UUID).
        XCTAssertEqual(removedCount, 4)

        // The user decision must survive, even though its title matches a demo title.
        let remaining = try context.fetch(FetchDescriptor<Decision>())
        XCTAssertEqual(remaining.count, 1)

        let survived = try XCTUnwrap(remaining.first)
        XCTAssertEqual(survived.title, "Should I start a small side project?")
        XCTAssertEqual(survived.notes, "This is MY decision, not the sample.")
        XCTAssertFalse(SampleData.containsDemoData(in: context))
    }
}
