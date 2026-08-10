//
//  PredictionResolutionService.swift
//  Hindsight
//
//  A small persistence boundary for the fast prediction-resolution flow.
//

import Foundation
import SwiftData

enum PredictionResolutionResult: Equatable {
    case saved
    case alreadyResolved
    case failed
}

enum PredictionResolutionService {
    /// Resolves one still-pending prediction. A failed save restores the in-memory
    /// model so the card remains visible while its note stays in the view state.
    @discardableResult
    static func resolve(
        _ prediction: Prediction,
        as status: PredictionStatus,
        note: String,
        in context: ModelContext
    ) -> PredictionResolutionResult {
        guard prediction.status == .pending else { return .alreadyResolved }
        guard status != .pending else { return .alreadyResolved }

        let previousStatus = prediction.status
        let previousResult = prediction.actualResult
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        prediction.status = status
        prediction.actualResult = trimmedNote.isEmpty ? nil : trimmedNote

        guard PersistenceService.saveOrReport(context) else {
            prediction.status = previousStatus
            prediction.actualResult = previousResult
            return .failed
        }
        return .saved
    }
}
