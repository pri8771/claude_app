//
//  OnboardingFinalCTAView.swift
//  Hindsight
//
//  Page 4: the close. A warm "seal your first decision" hero and the three
//  ways to begin — start a first decision, explore sample data, or start
//  empty. All paths are local-only.
//

import SwiftUI

struct OnboardingFinalCTAView: View {
    let onFirstDecision: () -> Void
    let onSampleData: () -> Void
    let onEmpty: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: HindsightTheme.Spacing.lg) {
                hero
                    .padding(.top, HindsightTheme.Spacing.lg)

                VStack(spacing: HindsightTheme.Spacing.sm) {
                    Text("See Hindsight in action")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(OnboardingTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Explore a few example decisions, reviews and insights. Remove them anytime.")
                        .font(.body)
                        .foregroundStyle(OnboardingTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, HindsightTheme.Spacing.sm)
                }

                VStack(spacing: HindsightTheme.Spacing.sm) {
                    OnboardingButton(title: "Explore the Demo", icon: "wand.and.stars",
                                     kind: .primary, action: onSampleData)
                    OnboardingButton(title: "Start First Decision", icon: "square.and.pencil",
                                     kind: .secondary, action: onFirstDecision)
                    OnboardingButton(title: "Start Empty", kind: .tertiary, action: onEmpty)
                }
                .padding(.top, HindsightTheme.Spacing.xs)

                Label("No account · No server · On-device only",
                      systemImage: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(OnboardingTheme.Colors.textSecondary)
                    .padding(.top, HindsightTheme.Spacing.xs)

                Color.clear.frame(height: HindsightTheme.Spacing.sm)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, HindsightTheme.Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Hero — a written page being sealed

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(OnboardingTheme.Colors.elevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(OnboardingTheme.Colors.border, lineWidth: 1)
                )
                .frame(width: 104, height: 104)

            Image(systemName: "doc.text.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(OnboardingTheme.Colors.textPrimary.opacity(0.92))
        }
        .overlay(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(OnboardingTheme.Colors.amber)
                    .frame(width: 42, height: 42)
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: "1A1A2E"))
            }
            .offset(x: 8, y: 8)
            .shadow(color: OnboardingTheme.Colors.amber.opacity(0.5), radius: 12, x: 0, y: 6)
        }
        .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 10)
    }
}

#Preview {
    ZStack {
        OnboardingBackground(page: 3).ignoresSafeArea()
        OnboardingFinalCTAView(onFirstDecision: {}, onSampleData: {}, onEmpty: {})
    }
}
