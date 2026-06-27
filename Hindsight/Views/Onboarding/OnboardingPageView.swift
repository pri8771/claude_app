//
//  OnboardingPageView.swift
//  Hindsight
//
//  Reusable scaffold for an onboarding page: an SF Symbol icon cluster, a
//  title block (optional eyebrow / subtitle / message) and a page-specific
//  accessory slot. Scrollable so it stays legible at large Dynamic Type
//  sizes.
//

import SwiftUI

struct OnboardingPageView<Accessory: View>: View {
    let iconCluster: [String]
    var eyebrow: String? = nil
    let title: String
    var isBrandTitle: Bool = false
    var subtitle: String? = nil
    var message: String? = nil
    @ViewBuilder var accessory: () -> Accessory

    var body: some View {
        ScrollView {
            VStack(spacing: HindsightTheme.Spacing.lg) {
                header
                    .padding(.top, HindsightTheme.Spacing.lg)

                textBlock

                accessory()

                Color.clear.frame(height: HindsightTheme.Spacing.sm)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, HindsightTheme.Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Header (single badge or a cinematic 3-icon cluster)

    @ViewBuilder private var header: some View {
        if iconCluster.count <= 1 {
            badge(iconCluster.first ?? "sparkles", size: 104,
                  tint: OnboardingTheme.Colors.accent,
                  fill: OnboardingTheme.Colors.elevated,
                  glow: true)
        } else {
            ZStack {
                if iconCluster.count > 1 {
                    badge(iconCluster[1], size: 74,
                          tint: OnboardingTheme.Colors.amber,
                          fill: OnboardingTheme.Colors.card)
                        .rotationEffect(.degrees(-12))
                        .offset(x: -64, y: 18)
                }
                if iconCluster.count > 2 {
                    badge(iconCluster[2], size: 74,
                          tint: OnboardingTheme.Colors.textSecondary,
                          fill: OnboardingTheme.Colors.card)
                        .rotationEffect(.degrees(12))
                        .offset(x: 64, y: 18)
                }
                badge(iconCluster[0], size: 104,
                      tint: OnboardingTheme.Colors.accent,
                      fill: OnboardingTheme.Colors.elevated,
                      glow: true)
            }
            .padding(.horizontal, HindsightTheme.Spacing.xl)
        }
    }

    private func badge(_ symbol: String, size: CGFloat, tint: Color, fill: Color, glow: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                        .strokeBorder(OnboardingTheme.Colors.border, lineWidth: 1)
                )
            Image(systemName: symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(tint)
                .symbolRenderingMode(.hierarchical)
        }
        .frame(width: size, height: size)
        .shadow(color: glow ? tint.opacity(0.45) : .black.opacity(0.35),
                radius: glow ? 22 : 10, x: 0, y: glow ? 10 : 6)
    }

    // MARK: Text block

    private var textBlock: some View {
        VStack(spacing: HindsightTheme.Spacing.sm) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.6)
                    .foregroundStyle(OnboardingTheme.Colors.amber)
            }

            Text(title)
                .font(isBrandTitle
                      ? .system(.largeTitle, design: .rounded).weight(.heavy)
                      : .system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(OnboardingTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            if let subtitle {
                Text(subtitle)
                    .font(.system(.title3, design: .rounded).weight(.medium))
                    .foregroundStyle(OnboardingTheme.Colors.amber)
                    .multilineTextAlignment(.center)
            }

            if let message {
                Text(message)
                    .font(.body)
                    .foregroundStyle(OnboardingTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HindsightTheme.Spacing.sm)
                    .padding(.top, 2)
            }
        }
        .padding(.top, HindsightTheme.Spacing.sm)
    }
}

#Preview {
    ZStack {
        OnboardingBackground(page: 0).ignoresSafeArea()
        OnboardingPageView(
            iconCluster: ["clock.arrow.circlepath", "lock.shield", "doc.text"],
            title: "Hindsight",
            isBrandTitle: true,
            subtitle: "Your private decision time machine.",
            message: "Record what you believe before reality gives you the answer."
        ) { EmptyView() }
    }
    .preferredColorScheme(.dark)
}
