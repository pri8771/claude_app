//
//  OnboardingDecisionLoopView.swift
//  Hindsight
//
//  Page 3 accessory: the four-step decision loop drawn as a vertical
//  timeline. The connecting line runs accent-red, and the two "review"
//  moments glow amber.
//

import SwiftUI

struct OnboardingDecisionLoopView: View {

    private struct Step: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let detail: String
        let isReview: Bool
    }

    private let steps: [Step] = [
        Step(icon: "square.and.pencil", title: "Capture a decision",
             detail: "Write down the choice and why it matters.", isReview: false),
        Step(icon: "scope", title: "Make predictions",
             detail: "State what you think will happen — and how sure you are.", isReview: false),
        Step(icon: "bell.badge.fill", title: "Come back later",
             detail: "Hindsight reminds you when it's time to look back.", isReview: true),
        Step(icon: "checkmark.seal.fill", title: "Compare with reality",
             detail: "Grade your past self and keep the lesson.", isReview: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                row(step, isLast: index == steps.count - 1, next: nextTint(after: index))
            }

            loopFooter
                .padding(.top, HindsightTheme.Spacing.sm)
        }
        .padding(HindsightTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OnboardingTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .strokeBorder(OnboardingTheme.Colors.border, lineWidth: 1)
        )
        .padding(.top, HindsightTheme.Spacing.sm)
    }

    // MARK: Row

    private func row(_ step: Step, isLast: Bool, next: Color) -> some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            // Node + connecting line
            VStack(spacing: 0) {
                node(step)
                if !isLast {
                    Rectangle()
                        .fill(LinearGradient(colors: [tint(step), next],
                                             startPoint: .top, endPoint: .bottom))
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 4)
                }
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.headline)
                    .foregroundStyle(OnboardingTheme.Colors.textPrimary)
                Text(step.detail)
                    .font(.subheadline)
                    .foregroundStyle(OnboardingTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if step.isReview {
                    Text("Review moment")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(OnboardingTheme.Colors.amber)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(OnboardingTheme.Colors.amber.opacity(0.14), in: Capsule())
                        .padding(.top, 2)
                }
            }
            .padding(.bottom, isLast ? 0 : HindsightTheme.Spacing.lg)

            Spacer(minLength: 0)
        }
    }

    private func node(_ step: Step) -> some View {
        ZStack {
            Circle()
                .fill(tint(step))
                .frame(width: 44, height: 44)
            Image(systemName: step.icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: tint(step).opacity(0.5), radius: step.isReview ? 12 : 6, x: 0, y: 4)
    }

    private var loopFooter: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.footnote.weight(.bold))
                .foregroundStyle(OnboardingTheme.Colors.accent)
            Text("Repeat the loop and your judgment compounds.")
                .font(.footnote)
                .foregroundStyle(OnboardingTheme.Colors.textSecondary)
            Spacer(minLength: 0)
        }
    }

    // MARK: Helpers

    private func tint(_ step: Step) -> Color {
        step.isReview ? OnboardingTheme.Colors.amber : OnboardingTheme.Colors.accent
    }

    private func nextTint(after index: Int) -> Color {
        let nextIndex = index + 1
        guard nextIndex < steps.count else { return OnboardingTheme.Colors.accent }
        return tint(steps[nextIndex])
    }
}

#Preview {
    ZStack {
        OnboardingBackground(page: 2).ignoresSafeArea()
        ScrollView { OnboardingDecisionLoopView().padding() }
    }
    .preferredColorScheme(.dark)
}
