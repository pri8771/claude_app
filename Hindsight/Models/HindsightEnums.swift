//
//  HindsightEnums.swift
//  Hindsight
//
//  All shared enumerations used across the data models and UI.
//

import SwiftUI

// MARK: - Decision Category

/// The life area a decision belongs to. Drives colour + iconography.
enum DecisionCategory: String, Codable, CaseIterable, Identifiable {
    case career        = "Career"
    case financial     = "Financial"
    case health        = "Health"
    case relationships = "Relationships"
    case personal      = "Personal"
    case creative      = "Creative"
    case education     = "Education"
    case other         = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .career:        return "briefcase.fill"
        case .financial:     return "dollarsign.circle.fill"
        case .health:        return "heart.fill"
        case .relationships: return "person.2.fill"
        case .personal:      return "person.fill"
        case .creative:      return "paintbrush.pointed.fill"
        case .education:     return "graduationcap.fill"
        case .other:         return "circle.grid.2x2.fill"
        }
    }

    /// A distinct accent colour for each category.
    var color: Color {
        switch self {
        case .career:        return Color(hex: "5B8DEF")
        case .financial:     return HindsightTheme.Colors.success
        case .health:        return Color(hex: "FF6B6B")
        case .relationships: return HindsightTheme.Colors.accent
        case .personal:      return Color(hex: "9B6BFF")
        case .creative:      return HindsightTheme.Colors.amber
        case .education:     return Color(hex: "4ECDC4")
        case .other:         return Color(hex: "8A8AA3")
        }
    }
}

// MARK: - Stakes Level

/// How consequential a decision is. Four levels, each with a description.
enum StakesLevel: String, Codable, CaseIterable, Identifiable {
    case low      = "Low"
    case medium   = "Medium"
    case high     = "High"
    case critical = "Critical"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .low:      return "Minor and easily reversible"
        case .medium:   return "Noticeable but manageable consequences"
        case .high:     return "Significant, lasting impact"
        case .critical: return "Life-changing and hard to undo"
        }
    }

    var icon: String {
        switch self {
        case .low:      return "leaf.fill"
        case .medium:   return "flag.fill"
        case .high:     return "exclamationmark.triangle.fill"
        case .critical: return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .low:      return HindsightTheme.Colors.success
        case .medium:   return HindsightTheme.Colors.amber
        case .high:     return Color(hex: "FF7849")
        case .critical: return HindsightTheme.Colors.accent
        }
    }

    /// Numeric weight used for sorting and analytics.
    var weight: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
}

// MARK: - Decision Status

/// Lifecycle state of a decision.
enum DecisionStatus: String, Codable, CaseIterable, Identifiable {
    case active         = "Active"
    case awaitingReview = "Awaiting Review"
    case reviewed       = "Reviewed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .active:         return "circle.dashed"
        case .awaitingReview: return "hourglass"
        case .reviewed:       return "checkmark.seal.fill"
        }
    }

    var color: Color {
        switch self {
        case .active:         return Color(hex: "5B8DEF")
        case .awaitingReview: return HindsightTheme.Colors.amber
        case .reviewed:       return HindsightTheme.Colors.success
        }
    }
}

// MARK: - Prediction Status

/// Whether a prediction came true once reality arrived.
enum PredictionStatus: String, Codable, CaseIterable, Identifiable {
    case pending   = "Pending"
    case correct   = "Correct"
    case incorrect = "Incorrect"
    case partial   = "Partial"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pending:   return "clock"
        case .correct:   return "checkmark.circle.fill"
        case .incorrect: return "xmark.circle.fill"
        case .partial:   return "circle.lefthalf.filled"
        }
    }

    var color: Color {
        switch self {
        case .pending:   return HindsightTheme.Colors.textSecondary
        case .correct:   return HindsightTheme.Colors.success
        case .incorrect: return HindsightTheme.Colors.accent
        case .partial:   return HindsightTheme.Colors.amber
        }
    }

    /// Fractional score used for prediction-accuracy analytics.
    var score: Double {
        switch self {
        case .correct:   return 1.0
        case .partial:   return 0.5
        case .incorrect: return 0.0
        case .pending:   return 0.0
        }
    }
}
