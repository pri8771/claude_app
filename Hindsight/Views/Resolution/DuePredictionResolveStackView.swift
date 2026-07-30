//
//  DuePredictionResolveStackView.swift
//  Hindsight
//
//  A focused, low-friction ritual for resolving each due prediction.
//

import SwiftUI
import SwiftData

struct DuePredictionResolveStackView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \Prediction.dueDate) private var predictions: [Prediction]

    @State private var note = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var lastAttemptedStatus: PredictionStatus = .correct

    private var duePredictions: [Prediction] {
        predictions.filter {
            $0.status == .pending &&
            $0.dueDate <= Date()
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()
                if let prediction = duePredictions.first {
                    resolveCard(for: prediction)
                        .id(prediction.id)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    emptyState
                }
            }
            .animation(.easeInOut, value: duePredictions.first?.id)
            .navigationTitle("Resolve Predictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .tint(HindsightTheme.Colors.textSecondary)
                }
            }
            .alert("Couldn't save", isPresented: Binding(
                get: { saveError != nil }, set: { if !$0 { saveError = nil } }
            )) {
                Button("Try Again") { resolveCurrent(as: lastAttemptedStatus) }
                Button("Keep Editing", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "Your result is still here. Try again when you're ready.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private func resolveCard(for prediction: Prediction) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                HCard(background: HindsightTheme.Colors.cardElevated) {
                    VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                        Text("Due for a look back")
                            .font(HindsightTheme.Typography.footnote)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        if let title = prediction.decision?.title, !title.isEmpty {
                            Text(title)
                                .font(HindsightTheme.Typography.headline)
                                .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        }
                        Text(prediction.title)
                            .font(HindsightTheme.Typography.title2)
                            .foregroundStyle(HindsightTheme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 8) {
                            HBadge(text: "\(prediction.probabilityPercent)% confidence", icon: "gauge.medium", color: HindsightTheme.Colors.amber)
                            HBadge(text: prediction.dueDate.formatted(.dateTime.month(.abbreviated).day()), icon: "calendar", color: HindsightTheme.Colors.textSecondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    HSectionHeader(title: "What happened?", subtitle: "Optional — a short note is enough", systemImage: "text.bubble.fill")
                    HTextEditor(text: $note, placeholder: "A few words for future you…", minHeight: 100,
                                accessibilityIdentifier: "resolvePrediction.note")
                }

                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    HSectionHeader(title: "How did it turn out?", subtitle: "Choose the closest match", systemImage: "scope")
                    verdictButton("Accurate", status: .correct, for: prediction)
                    verdictButton("Partly accurate", status: .partial, for: prediction)
                    verdictButton("Inaccurate", status: .incorrect, for: prediction)
                }
                Text("This saves the result and moves to the next due prediction.")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(HindsightTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .onAppear { note = "" }
    }

    private func verdictButton(_ title: String, status: PredictionStatus, for prediction: Prediction) -> some View {
        Button {
            resolve(prediction, as: status)
        } label: {
            HStack {
                Image(systemName: status.icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .font(HindsightTheme.Typography.headline)
            .foregroundStyle(status.color)
            .padding()
            .frame(maxWidth: .infinity)
            .background(status.color.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .accessibilityLabel("Mark prediction as \(title)")
        .accessibilityHint("Saves this result and shows the next due prediction")
    }

    private var emptyState: some View {
        VStack(spacing: HindsightTheme.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(HindsightTheme.Colors.success)
            Text("Nothing due right now")
                .font(HindsightTheme.Typography.title2)
                .foregroundStyle(HindsightTheme.Colors.textPrimary)
            Text("You can come back when another prediction is ready to revisit.")
                .font(HindsightTheme.Typography.body)
                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            HButton(title: "Done", icon: "checkmark") { dismiss() }
                .padding(.top, HindsightTheme.Spacing.sm)
        }
        .padding(HindsightTheme.Spacing.xl)
    }

    private func resolve(_ prediction: Prediction, as status: PredictionStatus) {
        guard !isSaving else { return }
        lastAttemptedStatus = status
        isSaving = true
        defer { isSaving = false }

        switch PredictionResolutionService.resolve(prediction, as: status, note: note, in: context) {
        case .saved:
            notificationManager.cancelReminder(for: prediction)
            HapticsManager.shared.selectionChanged()
            note = ""
        case .alreadyResolved:
            break
        case .failed:
            saveError = "Your result wasn't saved. The card and note are still ready to retry."
        }
    }

    private func resolveCurrent(as status: PredictionStatus) {
        guard let prediction = duePredictions.first else { return }
        resolve(prediction, as: status)
    }
}

#Preview {
    DuePredictionResolveStackView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
        .preferredColorScheme(.dark)
}
