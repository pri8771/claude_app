//
//  NotificationManager.swift
//  Hindsight
//
//  Thin wrapper around UNUserNotificationCenter for scheduling local
//  review reminders. Everything is on-device — no remote push.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private init() {
        Task { await refreshAuthorizationStatus() }
    }

    // MARK: Authorization

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    /// Requests permission. Safe to call repeatedly; returns the granted state.
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            await refreshAuthorizationStatus()
            return false
        }
    }

    // MARK: Scheduling

    /// Schedules a review reminder for a decision on its `dueDate`.
    func scheduleReviewReminder(for decision: Decision) {
        // Only schedule if reminders are enabled and the date is in the future.
        guard UserDefaults.standard.bool(forKey: AppStorageKeys.reviewReminders) else { return }
        guard decision.dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to review a decision"
        content.body = "Past you made a prediction about: \(decision.title)"
        content.sound = .default
        content.userInfo = ["decisionID": decision.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: decision.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: requestID(for: decision),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    /// Cancels any pending reminder for a decision.
    func cancelReminder(for decision: Decision) {
        center.removePendingNotificationRequests(withIdentifiers: [requestID(for: decision)])
    }

    /// Removes every pending reminder (used by "clear all data" and the toggle).
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    /// Re-schedules reminders for all decisions that still await review.
    func rescheduleAll(for decisions: [Decision]) {
        cancelAll()
        for decision in decisions where decision.status != .reviewed {
            scheduleReviewReminder(for: decision)
        }
    }

    private func requestID(for decision: Decision) -> String {
        "review-\(decision.id.uuidString)"
    }
}
