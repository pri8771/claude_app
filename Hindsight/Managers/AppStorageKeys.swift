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
}
