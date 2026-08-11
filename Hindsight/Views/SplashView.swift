//
//  SplashView.swift
//  Hindsight
//
//  A brief, elegant launch animation shown over the app at startup. The OS
//  launch screen paints the same deep indigo first (see the LaunchBackground
//  colour asset + UILaunchScreen in Hindsight-Info.plist), so this fades in
//  seamlessly with no white flash, then crossfades into the app.
//
//  No imported images — the mark is the shared SwiftUI `HindsightIconMark`.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "4D19C7"), Color(hex: "1B126D"), Color(hex: "071044")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "7C3AED").opacity(0.34))
                .frame(width: 360, height: 360)
                .blur(radius: 12)
                .offset(x: 150, y: -300)
                .accessibilityHidden(true)

            Circle()
                .fill(Color(hex: "00D8D6").opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 16)
                .offset(x: -170, y: 340)
                .accessibilityHidden(true)

            VStack(spacing: HindsightTheme.Spacing.lg) {
                HindsightIconMark(size: 120, rounded: true)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "8B5CF6").opacity(0.55), radius: 24, x: 0, y: 10)
                    .scaleEffect(appeared ? 1 : 0.92)

                VStack(spacing: HindsightTheme.Spacing.xs) {
                    Text("Hindsight")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    Text("Know your signal.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.72))
                }
                .opacity(appeared ? 1 : 0)
            }
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.easeOut(duration: 0.55)) { appeared = true }
            }
        }
    }
}

#Preview {
    SplashView()
}
