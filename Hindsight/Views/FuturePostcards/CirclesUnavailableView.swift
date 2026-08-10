//
//  CirclesUnavailableView.swift
//  Hindsight
//
//  Truthful gated destination. No account, network, relationship, or simulated activity exists.
//

import SwiftUI

struct CirclesUnavailableView: View {
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                FuturePostcardTheme.Colors.paper.ignoresSafeArea()
                VStack(spacing: 20) {
                    FuturePostcardStamp(text: "Personal first")
                    Image(systemName: "person.3")
                        .font(.system(size: 44, weight: .semibold))
                    Text("Circles aren’t enabled yet")
                        .font(FuturePostcardTheme.Typography.title)
                    Text("Your journal is still private and local. Friends, shared prediction lists, group analytics, and leaderboards will appear only after accounts, privacy controls, and the backend pass their release gates.")
                        .font(FuturePostcardTheme.Typography.body)
                        .foregroundStyle(FuturePostcardTheme.Colors.inkMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)
                    Button("Review your local data settings") {
                        showSettings = true
                    }
                    .font(FuturePostcardTheme.Typography.headline)
                    .foregroundStyle(FuturePostcardTheme.Colors.paperRaised)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 48)
                    .background(FuturePostcardTheme.Colors.ink)
                    .clipShape(Capsule())
                }
                .padding(28)
                .accessibilityElement(children: .contain)
            }
            .navigationTitle("Circles")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .futurePostcardScreen()
    }
}

#Preview {
    CirclesUnavailableView()
        .modelContainer(SampleData.previewContainer)
}
