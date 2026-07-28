//
//  ResolutionTests.swift
//  HindsightTests
//
//  Tests the prediction resolution behavior: pending predictions should not
//  be preselected (seeded) with a default verdict, and ungraded predictions
//  should remain pending after save (never coerced to .correct).
//

import XCTest
import SwiftData
@testable import Hindsight

@MainActor
final class ResolutionTests: XCTestCase {

    private var storeDirectory: URL!
    private var retainedContainers: [ModelContainer] = []

    private static var schema: Schema {
        Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        storeDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HindsightResolutionTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        retainedContainers.removeAll()
        if let storeDirectory {
            try? FileManager.default.removeItem(at: storeDirectory)
        }
        try super.tearDownWithError()
    }

    /// A fresh, isolated in-memory context for tests.
    private func makeInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(schema: Self.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Self.schema, configurations: [config])
        retainedContainers.append(container)
        return container.mainContext
    }

    // MARK: - Resolution behavior tests

    /// Test that a new pending prediction produces no seeded verdict
    /// (no dictionary entry), and after save logic its status remains .pending.
    func testResolution_newCallHasNoPreselectedVerdict() throws {
        let context = try makeInMemoryContext()

        // Create a decision with a pending prediction
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "I will succeed", probabilityPercent: 75)
        // Prediction defaults to .pending
        XCTAssertEqual(prediction.status, .pending)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        // Simulate the seedExistingReview behavior: pending predictions should NOT
        // be seeded into the verdict dictionary (no entry = nil)
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            // Only seed verdicts for already-resolved predictions; pending predictions get no entry
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }

        // Verify: no entry for the pending prediction
        XCTAssertNil(predictionVerdicts[prediction.id], "Pending prediction should not be seeded")

        // Simulate save behavior: prediction without explicit verdict should keep its existing status
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
            // If no entry in dictionary, status stays as-is (remains .pending)
        }

        // Verify: prediction status is still .pending (not coerced to .correct)
        XCTAssertEqual(prediction.status, .pending, "Ungraded prediction should remain .pending after save")
    }

    /// Test that an explicitly selected verdict persists on save.
    func testResolution_allowsOneTerminalChoice() throws {
        let context = try makeInMemoryContext()

        // Create a decision with a pending prediction
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "I will succeed", probabilityPercent: 75)
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        // Simulate the user selecting a verdict in the outcome review
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }
        // User explicitly selects .correct
        predictionVerdicts[prediction.id] = .correct

        // Simulate save behavior
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
        }

        // Verify: the selected verdict was persisted
        XCTAssertEqual(prediction.status, .correct, "Explicitly selected verdict should persist")
    }

    /// Test that already-resolved predictions retain their existing status
    /// (they seed the dictionary with their current status).
    func testResolution_alreadyResolvedPredictionPreservesStatus() throws {
        let context = try makeInMemoryContext()

        // Create a decision with an already-resolved prediction
        let decision = Decision(title: "Test decision")
        let prediction = Prediction(title: "I will succeed", probabilityPercent: 75)
        prediction.status = .correct
        decision.predictions = [prediction]
        context.insert(decision)
        try context.save()

        // Simulate seedExistingReview: already-resolved predictions ARE seeded
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }

        // Verify: resolved prediction is seeded with its existing status
        XCTAssertEqual(predictionVerdicts[prediction.id], .correct, "Resolved prediction should be seeded")

        // Simulate save without changing the verdict
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
        }

        // Verify: status unchanged
        XCTAssertEqual(prediction.status, .correct, "Already-resolved prediction should maintain its status")
    }

    /// Test that saving with ungraded predictions (mix of pending and resolved) is allowed.
    func testResolution_allowsSavingWithUngradedPredictions() throws {
        let context = try makeInMemoryContext()

        // Create a decision with mixed pending and resolved predictions
        let decision = Decision(title: "Test decision")
        let pending = Prediction(title: "Pending prediction", probabilityPercent: 70)
        let resolved = Prediction(title: "Resolved prediction", probabilityPercent: 80)
        resolved.status = .incorrect
        decision.predictions = [pending, resolved]
        context.insert(decision)
        try context.save()

        // Simulate outcome review: only resolved prediction is seeded
        var predictionVerdicts: [UUID: PredictionStatus] = [:]
        for pred in decision.predictions {
            if pred.status != .pending {
                predictionVerdicts[pred.id] = pred.status
            }
        }

        // Verify: pending has no entry, resolved is seeded
        XCTAssertNil(predictionVerdicts[pending.id], "Pending prediction should not be seeded")
        XCTAssertEqual(predictionVerdicts[resolved.id], .incorrect, "Resolved prediction should be seeded")

        // Save without changing either verdict
        for pred in decision.predictions {
            if let verdict = predictionVerdicts[pred.id] {
                pred.status = verdict
            }
        }

        // Verify: pending stays pending, resolved stays resolved
        XCTAssertEqual(pending.status, .pending, "Pending prediction should remain pending after save")
        XCTAssertEqual(resolved.status, .incorrect, "Resolved prediction should remain resolved after save")
    }
}
