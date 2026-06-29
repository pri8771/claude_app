//
//  ModelContext+Save.swift
//  Hindsight
//
//  A tiny helper that makes SwiftData saves observable instead of silent.
//  Every write in the app routes through `saveChanges()` so a failure can
//  be surfaced to the user rather than swallowed by `try?`.
//

import Foundation
import SwiftData
import os

private let persistenceLog = Logger(subsystem: "com.hindsight.app", category: "persistence")

extension ModelContext {
    /// Saves pending changes, logging (and optionally surfacing) any error.
    ///
    /// - Returns: `true` on success, `false` if the save threw.
    @discardableResult
    func saveChanges() -> Bool {
        guard hasChanges else { return true }
        do {
            try save()
            return true
        } catch {
            persistenceLog.error("SwiftData save failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
}
