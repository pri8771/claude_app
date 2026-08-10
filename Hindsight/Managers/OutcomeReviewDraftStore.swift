//
//  OutcomeReviewDraftStore.swift
//  Hindsight
//
//  Durable, per-decision recovery for an in-progress outcome review.
//

import Foundation

struct OutcomeReviewPredictionDraft: Codable, Equatable {
    let predictionID: UUID
    let verdict: PredictionStatus?
    let result: String
}

struct OutcomeReviewDraftSnapshot: Codable, Equatable {
    let decisionID: UUID
    let whatHappened: String
    let outcomeQuality: Int?
    let decisionQuality: Int?
    let wouldDoAgain: Bool?
    let whatSurprised: String
    let mainLesson: String
    let predictions: [OutcomeReviewPredictionDraft]

    var hasContent: Bool {
        !whatHappened.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        outcomeQuality != nil ||
        decisionQuality != nil ||
        wouldDoAgain != nil ||
        !whatSurprised.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !mainLesson.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        predictions.contains {
            $0.verdict != nil ||
            !$0.result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

enum OutcomeReviewDraftStore {
    private static let keyPrefix = "outcomeReviewDraft."

    static func load(for decisionID: UUID, defaults: UserDefaults = .standard) -> OutcomeReviewDraftSnapshot? {
        guard let data = defaults.data(forKey: key(for: decisionID)),
              let snapshot = try? JSONDecoder().decode(OutcomeReviewDraftSnapshot.self, from: data),
              snapshot.decisionID == decisionID
        else {
            return nil
        }
        return snapshot
    }

    static func save(_ snapshot: OutcomeReviewDraftSnapshot, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key(for: snapshot.decisionID))
    }

    static func clear(for decisionID: UUID, defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: key(for: decisionID))
    }

    /// Used by confirmed full-data deletion and store recovery after their
    /// SwiftData operation succeeds.
    static func clearAll(defaults: UserDefaults = .standard) {
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(keyPrefix) {
            defaults.removeObject(forKey: key)
        }
    }

    private static func key(for decisionID: UUID) -> String {
        keyPrefix + decisionID.uuidString
    }
}
