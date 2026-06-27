//
//  AppIconPreviewView.swift
//  Hindsight
//
//  The app icon "source of truth", drawn entirely with SwiftUI shapes —
//  no raster assets, no dependencies. `HindsightIconMark` is reused by the
//  launch/splash screen so the brand stays consistent, and this screen can
//  export a 1024×1024 PNG to fill the asset catalog (see
//  Docs/AppIconAndLaunchScreen.md).
//
//  Concept: a sealed decision on a private journal card.
//    • Dark navy rounded-square base
//    • A slightly lighter navy journal card
//    • An accent-red wax seal (the decision, committed)
//    • An amber time-arc sweeping around it, ending in a "future" spark
//

import SwiftUI
import UIKit

// MARK: - The icon artwork (vector, scalable)

struct HindsightIconMark: View {
    /// Edge length of the (square) icon canvas.
    var size: CGFloat = 1024
    /// `true` rounds the corners for in-app display; `false` renders a full
    /// opaque square for App Store export (iOS applies the icon mask itself).
    var rounded: Bool = true

    private var s: CGFloat { size }

    var body: some View {
        // The amber spark sits exactly at the end of the time-arc (t = 0.95
        // around a circle that starts at 3 o'clock and sweeps clockwise).
        let arcRadius = s * 0.205
        let sparkAngle = 2 * Double.pi * 0.95
        let sparkX = arcRadius * CGFloat(cos(sparkAngle))
        let sparkY = arcRadius * CGFloat(sin(sparkAngle))
        let sealDrop = s * 0.02   // seal sits just below the card's centre

        ZStack {
            base
            card
            timeArc.frame(width: arcRadius * 2, height: arcRadius * 2).offset(y: sealDrop)
            seal.offset(y: sealDrop)
            spark.offset(x: sparkX, y: sparkY + sealDrop)
        }
        .frame(width: s, height: s)
        .background(Color(hex: "1A1A2E"))
        .clipShape(clip)
    }

    // MARK: Base

    private var base: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "1E1E36"), Color(hex: "141428")],
                                     startPoint: .top, endPoint: .bottom))
            RadialGradient(colors: [Color(hex: "262648").opacity(0.9), .clear],
                           center: UnitPoint(x: 0.5, y: 0.32),
                           startRadius: 0, endRadius: s * 0.55)
            // A whisper of amber warmth at the bottom.
            RadialGradient(colors: [Color(hex: "F5A623").opacity(0.06), .clear],
                           center: UnitPoint(x: 0.5, y: 0.9),
                           startRadius: 0, endRadius: s * 0.5)
        }
    }

    // MARK: Journal card

    private var card: some View {
        RoundedRectangle(cornerRadius: s * 0.13, style: .continuous)
            .fill(LinearGradient(colors: [Color(hex: "2E2E50"), Color(hex: "242442")],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: s * 0.60, height: s * 0.70)
            .overlay(
                RoundedRectangle(cornerRadius: s * 0.13, style: .continuous)
                    .strokeBorder(Color(hex: "343456"), lineWidth: s * 0.008)
            )
            .overlay(alignment: .top) { pageLines.padding(.top, s * 0.115) }
            .shadow(color: .black.opacity(0.45), radius: s * 0.05, x: 0, y: s * 0.02)
    }

    /// Two faint "written" lines that imply a journal page without using text.
    private var pageLines: some View {
        VStack(spacing: s * 0.024) {
            Capsule().fill(Color(hex: "A7A7C7").opacity(0.16)).frame(width: s * 0.30, height: s * 0.012)
            Capsule().fill(Color(hex: "A7A7C7").opacity(0.11)).frame(width: s * 0.22, height: s * 0.012)
        }
    }

    // MARK: Accent-red wax seal

    private var seal: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Color(hex: "F0506A"), Color(hex: "E94560"), Color(hex: "C2334B")],
                                     center: UnitPoint(x: 0.40, y: 0.35),
                                     startRadius: s * 0.01, endRadius: s * 0.17))
                .frame(width: s * 0.26, height: s * 0.26)
                .shadow(color: Color(hex: "E94560").opacity(0.45), radius: s * 0.03, x: 0, y: s * 0.006)
            // Stamped inner ring.
            Circle()
                .strokeBorder(Color(hex: "1A1A2E").opacity(0.22), lineWidth: s * 0.012)
                .frame(width: s * 0.205, height: s * 0.205)
            // Glossy rim highlight.
            Circle()
                .strokeBorder(.white.opacity(0.12), lineWidth: s * 0.005)
                .frame(width: s * 0.255, height: s * 0.255)
        }
    }

    // MARK: Amber time-arc

    private var timeArc: some View {
        Circle()
            .trim(from: 0.55, to: 0.95)
            .stroke(LinearGradient(colors: [Color(hex: "F5A623"), Color(hex: "FFC65A")],
                                   startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: s * 0.026, lineCap: .round))
    }

    // MARK: Amber "future" spark

    private var spark: some View {
        ZStack {
            Circle().fill(Color(hex: "F5A623")).frame(width: s * 0.052, height: s * 0.052)
            Circle().fill(Color(hex: "FFD98A")).frame(width: s * 0.024, height: s * 0.024)
        }
        .shadow(color: Color(hex: "F5A623").opacity(0.85), radius: s * 0.03)
    }

    // MARK: Clip

    private var clip: AnyShape {
        rounded
            ? AnyShape(RoundedRectangle(cornerRadius: s * 0.2237, style: .continuous))
            : AnyShape(Rectangle())
    }
}

// MARK: - Preview / export screen

struct AppIconPreviewView: View {
    @State private var shareItem: ShareItem?
    @State private var exportError = false

    var body: some View {
        ScrollView {
            VStack(spacing: HindsightTheme.Spacing.xl) {
                VStack(spacing: HindsightTheme.Spacing.md) {
                    HindsightIconMark(size: 240, rounded: true)
                        .frame(width: 240, height: 240)
                        .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 14)
                    Text("Hindsight")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(hex: "F7F7FB"))
                    Text("App icon — drawn in SwiftUI, no raster assets")
                        .font(.footnote)
                        .foregroundStyle(Color(hex: "A7A7C7"))
                }

                // Small-size legibility check.
                VStack(spacing: HindsightTheme.Spacing.sm) {
                    Text("LEGIBILITY AT SMALL SIZES")
                        .font(.caption2.weight(.bold)).tracking(1.4)
                        .foregroundStyle(Color(hex: "A7A7C7"))
                    HStack(alignment: .bottom, spacing: HindsightTheme.Spacing.lg) {
                        ForEach([120.0, 80.0, 60.0, 40.0], id: \.self) { side in
                            VStack(spacing: 6) {
                                HindsightIconMark(size: side, rounded: true)
                                    .frame(width: side, height: side)
                                Text("\(Int(side))")
                                    .font(.caption2)
                                    .foregroundStyle(Color(hex: "A7A7C7"))
                            }
                        }
                    }
                }
                .padding(HindsightTheme.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "242442"))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color(hex: "343456"), lineWidth: 1))

                Button(action: exportIcon) {
                    Label("Export 1024×1024 PNG", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(LinearGradient(colors: [Color(hex: "E94560"), Color(hex: "C2334B")],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Text("Renders the full-square (un-rounded) source at 1024×1024 and opens a share sheet. Save it as AppIcon-1024.png, then drop it into the AppIcon slot. See Docs/AppIconAndLaunchScreen.md.")
                    .font(.caption)
                    .foregroundStyle(Color(hex: "A7A7C7"))
                    .multilineTextAlignment(.center)
            }
            .padding(HindsightTheme.Spacing.lg)
        }
        .background(Color(hex: "1A1A2E").ignoresSafeArea())
        .sheet(item: $shareItem) { ShareSheet(items: [$0.url]) }
        .alert("Export failed", isPresented: $exportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Couldn't render the icon PNG on this device.")
        }
    }

    @MainActor private func exportIcon() {
        let renderer = ImageRenderer(content:
            HindsightIconMark(size: 1024, rounded: false).frame(width: 1024, height: 1024))
        renderer.scale = 1
        guard let image = renderer.uiImage, let data = image.pngData() else {
            exportError = true
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("AppIcon-1024.png")
        do {
            try data.write(to: url, options: .atomic)
            shareItem = ShareItem(url: url)
        } catch {
            exportError = true
        }
    }
}

#Preview("Icon") {
    HindsightIconMark(size: 320, rounded: true)
        .frame(width: 320, height: 320)
        .padding(40)
        .background(Color(hex: "0F0F1E"))
}

#Preview("Export screen") {
    AppIconPreviewView()
        .preferredColorScheme(.dark)
}
