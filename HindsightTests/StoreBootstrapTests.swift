//
//  StoreBootstrapTests.swift
//  HindsightTests
//
//  Verifies that store open failures are recoverable and do not crash
//  the app. Tests both success and deliberately-bad-configuration paths.
//

import XCTest
import SwiftData

@MainActor
final class StoreBootstrapTests: XCTestCase {

    // MARK: Success path

    func testStoreOpenWithInMemoryConfigSucceeds() throws {
        // In-memory configuration should always succeed
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        let container = try StoreBootstrap.makeContainer(configuration: config)
        XCTAssertNotNil(container)

        // Verify we can interact with the container
        let descriptor = FetchDescriptor<Decision>()
        let count = try container.mainContext.fetchCount(descriptor)
        XCTAssertEqual(count, 0)
    }

    // MARK: Failure recovery

    func testStoreOpenFailureIsRecoverable() throws {
        // Deliberately create a bad configuration that points to an unwritable path,
        // proving that failure is catchable and does not crash.
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        let badURL = URL(fileURLWithPath: "/dev/null/hindsight-test-unwritable.store")
        let badConfig = ModelConfiguration(schema: schema, url: badURL)

        // This should throw, not crash.
        XCTAssertThrowsError(
            try StoreBootstrap.makeContainer(configuration: badConfig),
            "Opening a store at an unwritable path should throw"
        )
    }

    // MARK: Store file URLs

    func testStoreFileURLsReturnsThreePaths() {
        let urls = StoreBootstrap.storeFileURLs()

        // Should always return exactly three URLs: .store, -wal, -shm
        XCTAssertEqual(urls.count, 3)

        // All should end with the expected suffixes
        let paths = urls.map { $0.lastPathComponent }
        XCTAssertTrue(paths.contains { $0.hasSuffix(".store") })
        XCTAssertTrue(paths.contains { $0.hasSuffix(".store-wal") })
        XCTAssertTrue(paths.contains { $0.hasSuffix(".store-shm") })
    }

    func testStoreFileURLsPointToApplicationSupport() {
        let urls = StoreBootstrap.storeFileURLs()
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first

        XCTAssertNotNil(appSupport)

        // Each URL should reside in Application Support or the fallback temp directory
        for url in urls {
            let isInAppSupport = url.path.contains(appSupport?.path ?? "")
            XCTAssertTrue(isInAppSupport, "Store file \(url) should reside in Application Support")
        }
    }
}
