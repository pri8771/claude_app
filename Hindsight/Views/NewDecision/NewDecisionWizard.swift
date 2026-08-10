//
//  NewDecisionWizard.swift
//  Hindsight
//
//  A four-step sheet that captures a decision: basic info, the options
//  weighed, the predictions made, and the review date.
//

import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct NewDecisionWizard: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var draft = DecisionDraft()
    @State private var step = 0
    @State private var saveError: String?
    @State private var isSaving = false

    private let totalSteps = 4
    private let titles = ["Basics", "Options", "Predictions", "Review"]

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    progressBar

                    TabView(selection: $step) {
                        BasicInfoStep(draft: draft).tag(0)
                        OptionsStep(draft: draft).tag(1)
                        PredictionsStep(draft: draft).tag(2)
                        ReviewDateStep(draft: draft).tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: step)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                navigationButtons
            }
            .navigationTitle("New Decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.tint(HindsightTheme.Colors.textSecondary)
                }
            }
            .alert("Couldn't save decision", isPresented: Binding(
                get: { saveError != nil }, set: { if !$0 { saveError = nil } }
            )) {
                Button("Try Again") { save() }
                Button("Cancel", role: .cancel) { saveError = nil }
            } message: { Text(saveError ?? "An error occurred while saving your decision.") }
        }
        .interactiveDismissDisabled(!draft.title.isEmpty)
    }

    // MARK: Progress bar

    private var progressBar: some View {
        VStack(spacing: HindsightTheme.Spacing.sm) {
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index <= step ? HindsightTheme.Colors.accent : HindsightTheme.Colors.cardElevated)
                        .frame(height: 5)
                        .animation(.easeInOut, value: step)
                }
            }
            HStack {
                Text("Step \(step + 1) of \(totalSteps)")
                    .font(HindsightTheme.Typography.caption2)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                Spacer()
                Text(titles[step])
                    .font(HindsightTheme.Typography.subheadline)
                    .foregroundStyle(HindsightTheme.Colors.accent)
            }
        }
        .padding(.horizontal, HindsightTheme.Spacing.md)
        .padding(.vertical, HindsightTheme.Spacing.sm)
    }

    // MARK: Navigation buttons

    private var navigationButtons: some View {
        HStack(spacing: HindsightTheme.Spacing.md) {
            if step > 0 {
                HButton(title: "Back", icon: "chevron.left", style: .secondary, fullWidth: false) {
                    dismissKeyboard()
                    HapticsManager.shared.stepReversed()
                    withAnimation { step -= 1 }
                }
            }
            if step < totalSteps - 1 {
                HButton(title: "Next", icon: "chevron.right", isEnabled: currentStepValid) {
                    dismissKeyboard()
                    HapticsManager.shared.stepAdvanced()
                    withAnimation { step += 1 }
                }
            } else {
                HButton(
                    title: isSaving ? "Saving…" : "Save Decision",
                    icon: "checkmark.seal.fill",
                    isEnabled: canSave && !isSaving
                ) {
                    dismissKeyboard()
                    save()
                }
            }
        }
        .padding(HindsightTheme.Spacing.md)
        .background(HindsightTheme.Colors.surface.opacity(0.6))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(HindsightTheme.Colors.border)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }

    private var currentStepValid: Bool {
        switch step {
        case 0: return draft.step1Valid
        case 1: return draft.step2Valid
        case 2: return draft.step3Valid
        default: return true
        }
    }

    /// Saving requires every prior step to be valid, even if the user
    /// swiped ahead in the paged wizard.
    private var canSave: Bool {
        draft.step1Valid && draft.step2Valid && draft.step3Valid
    }

    /// A field on one page must not keep the keyboard over the next page. This
    /// matters most at accessibility text sizes, where the keyboard and footer
    /// otherwise leave too little room to reach the next page's first control.
    private func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        #endif
    }

    // MARK: Save

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        let decision = draft.makeDecision()

        // Attempt save; side effects (reminder scheduling, haptic, dismiss) only on success
        if NewDecisionGraphPersistenceService.save(decision, in: context) {
            // Only after successful save, schedule the reminder and fire success haptic
            Task { await notificationManager.scheduleReviewReminderIfAllowed(for: decision) }
            HapticsManager.shared.decisionSealed()
            dismiss()
        } else {
            isSaving = false
            saveError = "An error occurred while saving your decision."
        }
    }
}

#Preview {
    NewDecisionWizard()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
