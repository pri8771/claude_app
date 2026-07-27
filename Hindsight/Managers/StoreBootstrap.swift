//
//  StoreBootstrap.swift
//  Hindsight
//
//  Handles SwiftData container initialization with error recovery.
//  On failure, store files are left untouched until an explicit Reset
//  is requested by the user.
//

import Foundation
import SwiftData

enum StoreBootstrap {
    /// Attempts to open the default on-disk SwiftData container.
    /// Throws if the store cannot be opened; store files are not modified.
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        return try ModelContainer(for: schema)
    }

    /// Testable variant: accepts an explicit ModelConfiguration.
    /// Throws if the store cannot be opened.
    static func makeContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        let schema = Schema([Decision.self, DecisionOption.self, Prediction.self, OutcomeReview.self])
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    /// Returns the file URLs for the default store if it exists.
    /// Returns the paths for .store, .store-wal, and .store-shm files
    /// in the Application Support directory, regardless of actual existence.
    /// Caller can use these to check existence or delete during reset.
    static func storeFileURLs() -> [URL] {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        let baseName = "default.store"
        return [
            appSupport.appendingPathComponent(baseName),
            appSupport.appendingPathComponent(baseName + "-wal"),
            appSupport.appendingPathComponent(baseName + "-shm")
        ]
    }
}
