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
final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var tappedDecisionID: UUID?

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
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

    /// Requests notification permission only when needed, then schedules the
    /// reminder if the user has allowed local notifications.
    func scheduleReviewReminderIfAllowed(for decision: Decision) async {
        guard UserDefaults.standard.bool(forKey: AppStorageKeys.reviewReminders) else { return }

        await refreshAuthorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            guard await requestAuthorization() else { return }
            scheduleReviewReminder(for: decision)
        case .authorized, .provisional, .ephemeral:
            scheduleReviewReminder(for: decision)
        case .denied:
            return
        @unknown default:
            return
        }
    }

    // MARK: Scheduling

    /// Schedules a review reminder for a decision on its `dueDate`, plus a
    /// reminder for each prediction that has its own future due date.
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

        for prediction in decision.predictions {
            schedulePredictionReminder(prediction, for: decision)
        }
    }

    /// Schedules a reminder for an individual prediction whose `dueDate`
    /// differs from the owning decision's and lies in the future. Tapping it
    /// deep-links back to the owning decision, just like the decision reminder.
    private func schedulePredictionReminder(_ prediction: Prediction, for decision: Decision) {
        guard prediction.status == .pending else { return }
        guard prediction.dueDate > Date() else { return }
        // Skip predictions that share the decision's due date — the decision
        // reminder already covers that moment.
        guard prediction.dueDate != decision.dueDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "A prediction is due"
        content.body = "Time to grade: \(prediction.title)"
        content.sound = .default
        content.userInfo = ["decisionID": decision.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: prediction.dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: requestID(for: prediction),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    /// Cancels any pending reminder for a decision, including reminders for
    /// each of its predictions.
    func cancelReminder(for decision: Decision) {
        var ids = [requestID(for: decision)]
        ids.append(contentsOf: decision.predictions.map { requestID(for: $0) })
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Cancels the pending reminder for a single prediction (e.g. once its
    /// outcome has been recorded).
    func cancelReminder(for prediction: Prediction) {
        center.removePendingNotificationRequests(withIdentifiers: [requestID(for: prediction)])
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

    private func requestID(for prediction: Prediction) -> String {
        "prediction-\(prediction.id.uuidString)"
    }

    // MARK: Notification response

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let rawID = response.notification.request.content.userInfo["decisionID"] as? String
        Task { @MainActor in
            if let rawID, let decisionID = UUID(uuidString: rawID) {
                self.tappedDecisionID = decisionID
            }
            completionHandler()
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
