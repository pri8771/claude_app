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
//  Signal Garden concept: distinct probabilities orbit a central point of
//  clarity. The same mark appears in the launch experience; App Store assets
//  use the generated production rendering in Assets.xcassets.
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
        ZStack {
            base
            orbit
            probabilityDots
            centralSignal
        }
        .frame(width: s, height: s)
        .background(Color(hex: "110B55"))
        .clipShape(clip)
    }

    // MARK: Base

    private var base: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "4D19C7"), Color(hex: "1B126D"), Color(hex: "071044")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RadialGradient(
                colors: [Color(hex: "7C3AED").opacity(0.48), .clear],
                center: UnitPoint(x: 0.50, y: 0.18),
                startRadius: 0,
                endRadius: s * 0.62
            )
            RadialGradient(
                colors: [Color(hex: "00D8D6").opacity(0.12), .clear],
                center: UnitPoint(x: 0.56, y: 0.80),
                startRadius: 0,
                endRadius: s * 0.52
            )
        }
    }

    private var orbit: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        Color(hex: "FF4D8D"), Color(hex: "FF7B64"), Color(hex: "FFD33D"),
                        Color(hex: "B8FF32"), Color(hex: "35E8C6"), Color(hex: "34A8FF"),
                        Color(hex: "A86BFF"), Color(hex: "FF4D8D")
                    ],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: max(1, s * 0.014), lineCap: .round)
            )
            .frame(width: s * 0.68, height: s * 0.68)
            .shadow(color: Color(hex: "8B5CF6").opacity(0.44), radius: s * 0.03)
    }

    private var probabilityDots: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                let angle = (Double(index) / 20 * 360) - 90
                let radians = angle * Double.pi / 180
                let radius = s * 0.34
                let dotSize = s * dotScale(for: index)
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: dotSize, height: dotSize)
                    .shadow(color: dotColor(for: index).opacity(0.76), radius: max(1, s * 0.014))
                    .offset(
                        x: radius * CGFloat(cos(radians)),
                        y: radius * CGFloat(sin(radians))
                    )
            }
        }
    }

    private var centralSignal: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: s * 0.29, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: Color(hex: "FFB45C").opacity(0.90), radius: s * 0.035)
            Circle()
                .fill(Color.white.opacity(0.20))
                .frame(width: s * 0.12, height: s * 0.12)
                .blur(radius: s * 0.025)
        }
    }

    private func dotScale(for index: Int) -> CGFloat {
        switch index % 5 {
        case 0: return 0.067
        case 1: return 0.046
        case 2: return 0.031
        case 3: return 0.024
        default: return 0.039
        }
    }

    private func dotColor(for index: Int) -> Color {
        let palette = [
            Color(hex: "FFD33D"), Color(hex: "FF7B64"), Color(hex: "FF4D8D"),
            Color(hex: "A86BFF"), Color(hex: "34A8FF"), Color(hex: "35E8C6"),
            Color(hex: "B8FF32")
        ]
        return palette[index % palette.count]
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
}
