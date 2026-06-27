//
//  HapticsManager.swift
//  Hindsight
//
//  A small, centralized, native-only haptics service. Every haptic in the
//  app routes through here so it can be (a) consistent and (b) gated by the
//  user's "Haptic Feedback" preference.
//
//  Design intent: Hindsight is calm and reflective, not a game. Haptics
//  reinforce meaning — sealing a decision, resolving a prediction, closing
//  a loop — without being noisy.
//

import UIKit

/// A small vocabulary of haptic "feelings", decoupled from UIKit so call
/// sites (and the `View.haptics` modifier) don't need to import UIKit.
enum HapticPattern {
    case light, medium, heavy, rigid, soft   // impacts
    case success, warning, error             // notifications
    case selection                           // selection change
}

/// All haptics are triggered from the main thread (UI actions), where UIKit
/// feedback generators must run.
final class HapticsManager {

    /// Shared instance. All haptics in the app go through this.
    static let shared = HapticsManager()
    private init() {}

    // Reusable generators (impact generators are style-specific, so created on demand).
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    /// Honors the user's toggle. Defaults to ON when the key was never set,
    /// matching `@AppStorage("hapticsEnabled") = true` in Settings.
    var isEnabled: Bool {
        (UserDefaults.standard.object(forKey: AppStorageKeys.hapticsEnabled) as? Bool) ?? true
    }

    // MARK: - Primitive generators (native UIKit only)

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)
    }

    func selection() {
        guard isEnabled else { return }
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }

    /// Plays a pattern from the decoupled vocabulary.
    func play(_ pattern: HapticPattern) {
        switch pattern {
        case .light:     impact(.light)
        case .medium:    impact(.medium)
        case .heavy:     impact(.heavy)
        case .rigid:     impact(.rigid)
        case .soft:      impact(.soft)
        case .success:   notify(.success)
        case .warning:   notify(.warning)
        case .error:     notify(.error)
        case .selection: selection()
        }
    }

    // MARK: - Semantic moments
    //
    // Named for *what happened*, not how it feels, so intent stays clear at
    // the call site and the mapping lives in one place.

    /// 1. A decision is sealed (wizard final CTA). Satisfying, definitive.
    func decisionSealed() { notify(.success) }

    /// 2. Advancing a wizard step (Next / Continue). Subtle.
    func stepAdvanced() { impact(.light) }

    /// 3. Stepping back in the wizard. Softer than advancing.
    func stepReversed() { impact(.soft) }

    /// 4a. An option / prediction was added.
    func itemAdded() { impact(.medium) }

    /// 4b. An option / prediction was removed.
    func itemRemoved() { impact(.medium) }

    /// 5. An outcome review was submitted. Meaningful.
    func outcomeReviewed() { notify(.success) }

    /// 6. A prediction resolved correct. Clear and rewarding.
    func predictionResolvedCorrect() { notify(.success) }

    /// 7. A prediction resolved incorrect. Gentle, never harsh.
    func predictionResolvedIncorrect() { notify(.warning) }

    /// 8. A validation warning (e.g. a required field is empty). Gentle.
    func validationWarning() { notify(.warning) }

    /// 9. A destructive action was confirmed. Warning, not error.
    func deleteConfirmed() { notify(.warning) }

    /// 10. The onboarding page changed (swipe or Continue).
    func onboardingPageChanged() { impact(.light) }

    /// 11. Onboarding completed (a "Start" path was tapped).
    func onboardingCompleted() { impact(.medium) }

    /// 12. The main tab changed. Very subtle.
    func tabChanged() { selection() }

    /// Committing to / deciding an option. Crisp and decisive.
    func optionCommitted() { impact(.rigid) }

    /// A discrete selection changed (pickers, ratings, sliders, toggles).
    func selectionChanged() { selection() }
}
