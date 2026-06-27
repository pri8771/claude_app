//
//  OnboardingPrivacyCard.swift
//  Hindsight
//
//  Page 2 accessory: a warm card spelling out the three privacy promises.
//  Local-only storage · No analytics · No sign-in.
//

import SwiftUI

struct OnboardingPrivacyCard: View {

    private struct Promise: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let detail: String
    }

    private let promises: [Promise] = [
        Promise(icon: "internaldrive.fill", title: "Local-only storage",
                detail: "Everything is saved on this device with SwiftData."),
        Promise(icon: "eye.slash.fill", title: "No analytics",
                detail: "Nothing you write is measured, tracked, or phoned home."),
        Promise(icon: "person.crop.circle.badge.xmark", title: "No sign-in",
                detail: "No account, no email, no password. Just open and write.")
    ]

    var body: some View {
        VStack(spacing: HindsightTheme.Spacing.md) {
            ForEach(promises) { promise in
                row(promise)
            }
        }
        .padding(HindsightTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(OnboardingTheme.Colors.card)
        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                .strokeBorder(OnboardingTheme.Colors.border, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            // A warm amber lock badge that anchors the "private" promise.
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(OnboardingTheme.Colors.amber)
                .padding(10)
                .background(OnboardingTheme.Colors.amber.opacity(0.14), in: Circle())
                .offset(x: -HindsightTheme.Spacing.md, y: HindsightTheme.Spacing.md)
        }
        .padding(.top, HindsightTheme.Spacing.sm)
    }

    private func row(_ promise: Promise) -> some View {
        HStack(alignment: .top, spacing: HindsightTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(OnboardingTheme.Colors.accent.opacity(0.16))
                    .frame(width: 42, height: 42)
                Image(systemName: promise.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(OnboardingTheme.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(promise.title)
                    .font(.headline)
                    .foregroundStyle(OnboardingTheme.Colors.textPrimary)
                Text(promise.detail)
                    .font(.subheadline)
                    .foregroundStyle(OnboardingTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    ZStack {
        OnboardingBackground(page: 1).ignoresSafeArea()
        OnboardingPrivacyCard().padding()
    }
    .preferredColorScheme(.dark)
}
