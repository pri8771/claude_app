//
//  AppStorageKeys.swift
//  Hindsight
//
//  Centralised UserDefaults / @AppStorage key names.
//

import Foundation

enum AppStorageKeys {
    /// The user's display name shown in the greeting.
    static let userName          = "userName"
    /// Whether review reminders are enabled.
    static let reviewReminders   = "reviewReminders"
    /// Whether the notification-permission prompt has been shown once.
    static let didRequestNotifications = "didRequestNotifications"
    /// Whether the user has completed first-run setup.
    static let hasLaunchedBefore = "hasLaunchedBefore"
    /// Whether the first-run onboarding flow has been completed.
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    /// Whether haptic feedback is enabled.
    static let hapticsEnabled = "hapticsEnabled"
    /// Whether the one-time quick-capture short-horizon suggestion was dismissed or completed.
    static let didCompleteQuickCaptureNudge = "didCompleteQuickCaptureNudge"
    /// Recoverable in-progress content for the one-sheet Quick Capture flow.
    static let quickCaptureDraft = "quickCaptureDraft"
}
