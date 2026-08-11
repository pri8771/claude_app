//
//  DuePredictionResolveStackView.swift
//  Hindsight
//
//  A focused, low-friction ritual for resolving each due prediction.
//

import SwiftUI
import SwiftData

enum PredictionResolutionDraftStore {
    private static func drafts(defaults: UserDefaults) -> [String: String] {
        guard let data = defaults.data(forKey: AppStorageKeys.predictionResolutionDrafts) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }

    static func load(for predictionID: UUID, defaults: UserDefaults = .standard) -> String {
        drafts(defaults: defaults)[predictionID.uuidString] ?? ""
    }

    static func save(_ note: String, for predictionID: UUID, defaults: UserDefaults = .standard) {
        var values = drafts(defaults: defaults)
        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            values.removeValue(forKey: predictionID.uuidString)
        } else {
            values[predictionID.uuidString] = note
        }
        if values.isEmpty {
            defaults.removeObject(forKey: AppStorageKeys.predictionResolutionDrafts)
        } else if let data = try? JSONEncoder().encode(values) {
            defaults.set(data, forKey: AppStorageKeys.predictionResolutionDrafts)
        }
    }

    static func clear(for predictionID: UUID, defaults: UserDefaults = .standard) {
        save("", for: predictionID, defaults: defaults)
    }

    static func clearAll(defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: AppStorageKeys.predictionResolutionDrafts)
    }
}

struct DuePredictionResolveStackView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \Prediction.dueDate) private var predictions: [Prediction]

    @State private var note = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var lastAttemptedStatus: PredictionStatus = .partial
    @State private var showNote = false
    @State private var showDismissDraftConfirmation = false

    private var duePredictions: [Prediction] {
        predictions.filter {
            $0.status == .pending &&
            $0.dueDate <= Date() &&
            ($0.decision.map { !SampleData.isDemoDecision($0) } ?? true)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HindsightTheme.Colors.backgroundGradient.ignoresSafeArea()
                if let prediction = duePredictions.first {
                    resolveCard(for: prediction)
                        .id(prediction.id)
                        .transition(reduceMotion ? .identity : .opacity.combined(with: .scale(scale: 0.97)))
                } else {
                    emptyState
                }
            }
            .animation(reduceMotion ? nil : .spring(response: 0.42, dampingFraction: 0.84), value: duePredictions.first?.id)
            .navigationTitle("Reality check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        if hasOutcomeContextDraft {
                            showDismissDraftConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
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
            .confirmationDialog("Keep outcome context for later?", isPresented: $showDismissDraftConfirmation, titleVisibility: .visible) {
                Button("Keep Draft") { dismiss() }
                Button("Discard Context", role: .destructive) {
                    if let prediction = duePredictions.first {
                        PredictionResolutionDraftStore.clear(for: prediction.id)
                    }
                    note = ""
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your outcome context is saved on this device until you resolve this forecast or discard it.")
            }
        }
        .interactiveDismissDisabled(hasOutcomeContextDraft || isSaving)
    }

    private func resolveCard(for prediction: Prediction) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HindsightTheme.Spacing.lg) {
                resolutionHeader
                forecastReveal(for: prediction)

                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Button {
                        if reduceMotion { showNote.toggle() }
                        else { withAnimation(.easeInOut(duration: 0.2)) { showNote.toggle() } }
                    } label: {
                        HStack(spacing: HindsightTheme.Spacing.md) {
                            ZStack {
                                Circle().fill(HindsightTheme.Colors.categoryEducation.opacity(0.13))
                                Image(systemName: "text.bubble.fill")
                                    .foregroundStyle(HindsightTheme.Colors.categoryEducation)
                            }
                            .frame(width: 40, height: 40)
                            .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add what you learned")
                                    .font(HindsightTheme.Typography.headline)
                                Text("Optional; add it before choosing an outcome")
                                    .font(HindsightTheme.Typography.footnote)
                                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: showNote ? "chevron.up" : "plus")
                                .foregroundStyle(HindsightTheme.Colors.steel)
                        }
                        .padding(HindsightTheme.Spacing.md)
                        .frame(minHeight: 56)
                        .background(HindsightTheme.Colors.card)
                        .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(showNote ? "Hide optional outcome context" : "Add optional outcome context")
                    if showNote {
                        HTextEditor(text: noteBinding(for: prediction), placeholder: "What made the outcome clear?", minHeight: 100,
                                    accessibilityIdentifier: "resolvePrediction.note",
                                    accessibilityLabel: "Optional outcome context")
                    }
                }
                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.sm) {
                    Text("What did reality say?")
                        .font(HindsightTheme.Typography.title)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    Text("Choose the honest answer. Nothing is selected for you.")
                        .font(HindsightTheme.Typography.footnote)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    verdictButton("It happened", subtitle: "Yes — count this as correct", status: .correct, icon: "checkmark", color: HindsightTheme.Colors.success, for: prediction)
                    verdictButton("It did not happen", subtitle: "No — count this as incorrect", status: .incorrect, icon: "xmark", color: HindsightTheme.Colors.accent, for: prediction)
                    verdictButton("It cannot be judged clearly", subtitle: "Keep it visible, but exclude it from calibration", status: .partial, icon: "questionmark", color: HindsightTheme.Colors.categoryPersonal, for: prediction)
                }
                Label("Your answer is saved immediately, then the next due signal appears.", systemImage: "lock.fill")
                    .font(HindsightTheme.Typography.caption)
                    .foregroundStyle(HindsightTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(HindsightTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            note = PredictionResolutionDraftStore.load(for: prediction.id)
            showNote = !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var resolutionHeader: some View {
        HStack(alignment: .center, spacing: HindsightTheme.Spacing.md) {
            ZStack {
                Circle().fill(HindsightTheme.Colors.accentGradient)
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 54, height: 54)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("THE MOMENT OF TRUTH")
                    .font(HindsightTheme.Typography.metadata)
                    .tracking(0.8)
                    .foregroundStyle(HindsightTheme.Colors.accent)
                Text(duePredictions.count == 1 ? "One signal is ready" : "\(duePredictions.count) signals are ready")
                    .font(HindsightTheme.Typography.title)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func forecastReveal(for prediction: Prediction) -> some View {
        HCard(padding: 0, background: HindsightTheme.Colors.card) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [
                        HindsightTheme.Colors.categoryPersonal.opacity(0.20),
                        HindsightTheme.Colors.categoryEducation.opacity(0.12),
                        HindsightTheme.Colors.amber.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(HindsightTheme.Colors.amber.opacity(0.16))
                    .frame(width: 140, height: 140)
                    .offset(x: 52, y: -64)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: HindsightTheme.Spacing.md) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("YOU SAID")
                                .font(HindsightTheme.Typography.metadata)
                                .foregroundStyle(HindsightTheme.Colors.categoryPersonal)
                            Text(prediction.dueDate.formatted(.dateTime.month(.wide).day().year()))
                                .font(HindsightTheme.Typography.footnote)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                        Spacer()
                        VStack(spacing: 0) {
                            Text("\(prediction.probabilityPercent)%")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(HindsightTheme.Colors.accent)
                                .monospacedDigit()
                            Text("confident")
                                .font(HindsightTheme.Typography.caption2)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(HindsightTheme.Colors.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                    }

                    if let title = prediction.decision?.title,
                       !title.isEmpty,
                       title != prediction.title {
                        Text(title)
                            .font(HindsightTheme.Typography.headline)
                            .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    }
                    Text(prediction.title)
                        .font(HindsightTheme.Typography.authoredStatement)
                        .foregroundStyle(HindsightTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let decision = prediction.decision, !decision.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Your original thinking", systemImage: "quote.bubble.fill")
                                .font(HindsightTheme.Typography.caption2)
                                .foregroundStyle(HindsightTheme.Colors.categoryEducation)
                            Text(decision.notes)
                                .font(HindsightTheme.Typography.callout)
                                .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        }
                        .padding(HindsightTheme.Spacing.md)
                        .background(HindsightTheme.Colors.surface.opacity(0.70), in: RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
                    }
                    if let decision = prediction.decision, SampleData.isDemoDecision(decision) {
                        HBadge(text: "Example only · excluded from insights", icon: "wand.and.stars", color: HindsightTheme.Colors.amber)
                    }
                }
                .padding(HindsightTheme.Spacing.lg)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func verdictButton(
        _ title: String,
        subtitle: String,
        status: PredictionStatus,
        icon: String,
        color: Color,
        for prediction: Prediction
    ) -> some View {
        Button {
            resolve(prediction, as: status)
        } label: {
            HStack(spacing: HindsightTheme.Spacing.md) {
                ZStack {
                    Circle().fill(color)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 42, height: 42)
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(HindsightTheme.Typography.headline)
                    Text(subtitle)
                        .font(HindsightTheme.Typography.caption)
                        .foregroundStyle(HindsightTheme.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(HindsightTheme.Colors.textPrimary)
            .padding(HindsightTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(HindsightTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: HindsightTheme.Radius.lg, style: .continuous)
                    .stroke(color.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
        .accessibilityLabel(title)
        .accessibilityHint("Saves this result and shows the next due prediction")
    }

    private var emptyState: some View {
        ZStack {
            SignalConfetti()
                .opacity(reduceMotion ? 0.45 : 1)
                .accessibilityHidden(true)
            VStack(spacing: HindsightTheme.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [HindsightTheme.Colors.success, HindsightTheme.Colors.categoryEducation],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 82, height: 82)
                .hindsightShadow(HindsightTheme.Shadows.glow)
                Text("You closed the loop")
                    .font(HindsightTheme.Typography.editorialDisplay)
                    .foregroundStyle(HindsightTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Every honest resolution makes your personal signal clearer.")
                    .font(HindsightTheme.Typography.body)
                    .foregroundStyle(HindsightTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                HButton(title: "Back to Today", icon: "arrow.right", action: { dismiss() })
                    .padding(.top, HindsightTheme.Spacing.sm)
            }
            .padding(HindsightTheme.Spacing.xl)
        }
    }

    private func resolve(_ prediction: Prediction, as status: PredictionStatus) {
        guard !isSaving else { return }
        lastAttemptedStatus = status
        isSaving = true
        defer { isSaving = false }

        switch PredictionResolutionService.resolve(prediction, as: status, note: note, in: context) {
        case .saved:
            PredictionResolutionDraftStore.clear(for: prediction.id)
            notificationManager.cancelReminder(for: prediction)
            HapticsManager.shared.selectionChanged()
            note = ""
            showNote = false
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

    private var hasOutcomeContextDraft: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func noteBinding(for prediction: Prediction) -> Binding<String> {
        Binding(
            get: { note },
            set: { newValue in
                note = newValue
                PredictionResolutionDraftStore.save(newValue, for: prediction.id)
            }
        )
    }
}

private struct SignalConfetti: View {
    private let colors: [Color] = [
        HindsightTheme.Colors.accent,
        HindsightTheme.Colors.amber,
        HindsightTheme.Colors.success,
        HindsightTheme.Colors.categoryEducation,
        HindsightTheme.Colors.categoryHealth
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<18, id: \.self) { index in
                Capsule()
                    .fill(colors[index % colors.count])
                    .frame(width: index.isMultiple(of: 3) ? 8 : 5, height: index.isMultiple(of: 2) ? 18 : 11)
                    .rotationEffect(.degrees(Double(index * 37)))
                    .position(
                        x: proxy.size.width * CGFloat((index * 29) % 100) / 100,
                        y: proxy.size.height * CGFloat((index * 43) % 90) / 100
                    )
            }
        }
    }
}

#Preview {
    DuePredictionResolveStackView()
        .environmentObject(NotificationManager.shared)
        .modelContainer(SampleData.previewContainer)
}
