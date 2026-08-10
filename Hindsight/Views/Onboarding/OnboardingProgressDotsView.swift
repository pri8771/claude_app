//
//  OnboardingProgressDotsView.swift
//  Hindsight
//
//  Page indicator for the onboarding flow. The active page is shown as an
//  elongated accent pill; the rest are subtle dots.
//

import SwiftUI

struct OnboardingProgressDotsView: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: HindsightTheme.Spacing.sm) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? OnboardingTheme.Colors.accent : OnboardingTheme.Colors.border)
                    .frame(width: i == index ? 24 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: index)
        .accessibilityElement()
        .accessibilityLabel("Page \(index + 1) of \(count)")
    }
}

#Preview {
    ZStack {
        OnboardingTheme.Colors.background.ignoresSafeArea()
        VStack(spacing: 24) {
            OnboardingProgressDotsView(count: 4, index: 0)
            OnboardingProgressDotsView(count: 4, index: 2)
        }
    }
}
