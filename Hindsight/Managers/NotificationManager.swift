//
//  NotificationManager.swift
//  Hindsight
//
//  Thin wrapper around UNUserNotificationCenter for scheduling local
//  review reminders. Everything is on-device — no remote push.
//

import Foundation
import UserNotifications
import os

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()
    private let log = Logger(subsystem: "com.hindsight.app", category: "notifications")

    /// Local hour of day (24h) at which review reminders fire, so a reminder
    /// never wakes the user at whatever clock time the decision was created.
    private let reviewReminderHour = 9

    /// iOS allows at most 64 pending local notifications per app. We keep a
    /// safety margin and schedule the soonest reviews when over the limit.
    private let maxPendingReminders = 60

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

    /// Schedules a review reminder for a decision, fired at a sensible hour
    /// on its `dueDate`. No-op if reminders are disabled or the fire time has
    /// already passed (those decisions surface in "Needs Review" instead).
    func scheduleReviewReminder(for decision: Decision) {
        guard UserDefaults.standard.bool(forKey: AppStorageKeys.reviewReminders) else { return }
        guard let fireDate = reminderFireDate(for: decision), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to review a decision"
        content.body = "Past you made a prediction about: \(decision.title)"
        content.sound = .default
        content.userInfo = ["decisionID": decision.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: requestID(for: decision),
            content: content,
            trigger: trigger
        )
        center.add(request) { [log] error in
            if let error {
                log.error("Failed to schedule reminder: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    /// The moment a reminder should fire: `reviewReminderHour` local time on
    /// the decision's review day.
    private func reminderFireDate(for decision: Decision) -> Date? {
        let calendar = Calendar.current
        return calendar.date(
            bySettingHour: reviewReminderHour, minute: 0, second: 0,
            of: decision.dueDate, matchingPolicy: .nextTime
        )
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
    /// When more than `maxPendingReminders` reviews are pending, only the
    /// soonest are scheduled so we never silently exceed the iOS 64 cap.
    func rescheduleAll(for decisions: [Decision]) {
        cancelAll()
        let pending = decisions
            .filter { $0.status != .reviewed }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(maxPendingReminders)
        for decision in pending {
            scheduleReviewReminder(for: decision)
        }
    }

    private func requestID(for decision: Decision) -> String {
        "review-\(decision.id.uuidString)"
    }
}
