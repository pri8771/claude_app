//
//  SplashView.swift
//  Hindsight
//
//  A brief, elegant launch animation shown over the app at startup. The OS
//  launch screen paints the same dark navy first (see the LaunchBackground
//  colour asset + UILaunchScreen in Hindsight-Info.plist), so this fades in
//  seamlessly with no white flash, then crossfades into the app.
//
//  No imported images — the mark is the shared SwiftUI `HindsightIconMark`.
//

import SwiftUI

struct SplashView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(hex: "1A1A2E").ignoresSafeArea()

            VStack(spacing: HindsightTheme.Spacing.lg) {
                HindsightIconMark(size: 112, rounded: true)
                    .frame(width: 112, height: 112)
                    .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 10)
                    .scaleEffect(appeared ? 1 : 0.92)

                VStack(spacing: HindsightTheme.Spacing.xs) {
                    Text("Hindsight")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(hex: "F7F7FB"))
                    Text("Your private decision time machine.")
                        .font(.footnote)
                        .foregroundStyle(Color(hex: "A7A7C7"))
                }
                .opacity(appeared ? 1 : 0)
            }
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) { appeared = true }
        }
    }
}

#Preview {
    SplashView()
}
