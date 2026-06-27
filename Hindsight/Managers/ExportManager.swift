//
//  ExportManager.swift
//  Hindsight
//
//  Exports the journal as JSON or a printable PDF. Everything is written
//  to a temporary file the user can share — no data leaves the device
//  unless the user explicitly shares it.
//

import Foundation
import UIKit

// MARK: - Codable transfer objects

/// A snapshot of the whole journal, used for JSON export.
struct JournalExport: Codable {
    let exportedAt: Date
    let appVersion: String
    let decisions: [DecisionExport]
}

struct DecisionExport: Codable {
    let title: String
    let notes: String
    let category: String
    let stakesLevel: String
    let status: String
    let isReversible: Bool
    let clarityScore: Int
    let chosenOptionTitle: String?
    let createdAt: Date
    let dueDate: Date
    let options: [OptionExport]
    let predictions: [PredictionExport]
    let outcomeReview: OutcomeReviewExport?
}

struct OptionExport: Codable {
    let title: String
    let upside: String
    let downside: String
    let effortLevel: Int
    let riskLevel: Int
    let gutFeeling: Int
}

struct PredictionExport: Codable {
    let statement: String
    let probabilityPercent: Int
    let dueDate: Date
    let status: String
    let actualResult: String?
}

struct OutcomeReviewExport: Codable {
    let whatHappened: String
    let outcomeQuality: Int
    let decisionQuality: Int
    let wouldDoAgain: Bool
    let whatSurprised: String
    let mainLesson: String
    let reviewedAt: Date
}

// MARK: - Manager

enum ExportError: Error { case writeFailed }

enum ExportManager {

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    // MARK: JSON

    static func makeExport(from decisions: [Decision]) -> JournalExport {
        JournalExport(
            exportedAt: Date(),
            appVersion: appVersion,
            decisions: decisions.map { decision in
                DecisionExport(
                    title: decision.title,
                    notes: decision.notes,
                    category: decision.category.rawValue,
                    stakesLevel: decision.stakesLevel.rawValue,
                    status: decision.status.rawValue,
                    isReversible: decision.isReversible,
                    clarityScore: decision.clarityScore,
                    chosenOptionTitle: decision.chosenOptionTitle,
                    createdAt: decision.createdAt,
                    dueDate: decision.dueDate,
                    options: decision.options.map {
                        OptionExport(title: $0.title, upside: $0.upside, downside: $0.downside,
                                     effortLevel: $0.effortLevel, riskLevel: $0.riskLevel,
                                     gutFeeling: $0.gutFeeling)
                    },
                    predictions: decision.predictions.map {
                        PredictionExport(statement: $0.title, probabilityPercent: $0.probabilityPercent,
                                         dueDate: $0.dueDate, status: $0.status.rawValue,
                                         actualResult: $0.actualResult)
                    },
                    outcomeReview: decision.outcomeReview.map {
                        OutcomeReviewExport(whatHappened: $0.whatHappened, outcomeQuality: $0.outcomeQuality,
                                            decisionQuality: $0.decisionQuality, wouldDoAgain: $0.wouldDoAgain,
                                            whatSurprised: $0.whatSurprised, mainLesson: $0.mainLesson,
                                            reviewedAt: $0.reviewedAt)
                    }
                )
            }
        )
    }

    /// Writes the journal to a temporary JSON file and returns its URL.
    static func exportJSON(_ decisions: [Decision]) throws -> URL {
        let export = makeExport(from: decisions)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(export)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Hindsight-Journal-\(fileTimestamp()).json")
        try data.write(to: url, options: .atomic)
        return url
    }

    // MARK: PDF

    /// Renders a simple paginated PDF report and returns its URL.
    static func exportPDF(_ decisions: [Decision]) throws -> URL {
        let pageSize = CGSize(width: 612, height: 792) // US Letter @ 72dpi
        let margin: CGFloat = 48
        let contentWidth = pageSize.width - margin * 2

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "Hindsight Journal",
            kCGPDFContextCreator as String: "Hindsight"
        ]
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Hindsight-Journal-\(fileTimestamp()).pdf")

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium

        try renderer.writePDF(to: url) { ctx in
            var cursorY: CGFloat = margin
            ctx.beginPage()

            func newPageIfNeeded(_ needed: CGFloat) {
                if cursorY + needed > pageSize.height - margin {
                    ctx.beginPage()
                    cursorY = margin
                }
            }

            func draw(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 6) {
                let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let bounding = (text as NSString).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes, context: nil)
                newPageIfNeeded(bounding.height + spacingAfter)
                (text as NSString).draw(
                    with: CGRect(x: margin, y: cursorY, width: contentWidth, height: bounding.height),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes, context: nil)
                cursorY += bounding.height + spacingAfter
            }

            func divider() {
                newPageIfNeeded(16)
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: cursorY))
                path.addLine(to: CGPoint(x: pageSize.width - margin, y: cursorY))
                UIColor(white: 0.85, alpha: 1).setStroke()
                path.lineWidth = 0.5
                path.stroke()
                cursorY += 16
            }

            // Header
            draw("Hindsight", font: .systemFont(ofSize: 28, weight: .bold),
                 color: UIColor(red: 0.91, green: 0.27, blue: 0.38, alpha: 1), spacingAfter: 2)
            draw("Remember what you believed before reality gave you the answer.",
                 font: .systemFont(ofSize: 11, weight: .regular), color: .gray, spacingAfter: 4)
            draw("Exported \(dateFormatter.string(from: Date())) · \(decisions.count) decisions",
                 font: .systemFont(ofSize: 11, weight: .medium), color: .darkGray, spacingAfter: 12)
            divider()

            for decision in decisions {
                draw(decision.title, font: .systemFont(ofSize: 18, weight: .bold), spacingAfter: 2)
                draw("\(decision.category.rawValue) · \(decision.stakesLevel.rawValue) stakes · \(decision.status.rawValue) · Clarity \(decision.clarityScore)%",
                     font: .systemFont(ofSize: 10, weight: .medium), color: .gray, spacingAfter: 6)

                if !decision.notes.isEmpty {
                    draw(decision.notes, font: .systemFont(ofSize: 11), color: .darkGray)
                }

                if !decision.options.isEmpty {
                    draw("Options considered", font: .systemFont(ofSize: 12, weight: .semibold), spacingAfter: 4)
                    for opt in decision.options {
                        let chosen = (opt.title == decision.chosenOptionTitle) ? " ✓ chosen" : ""
                        draw("• \(opt.title)\(chosen)", font: .systemFont(ofSize: 11, weight: .medium))
                        if !opt.upside.isEmpty { draw("   + \(opt.upside)", font: .systemFont(ofSize: 10), color: .darkGray, spacingAfter: 2) }
                        if !opt.downside.isEmpty { draw("   – \(opt.downside)", font: .systemFont(ofSize: 10), color: .darkGray, spacingAfter: 2) }
                    }
                    cursorY += 4
                }

                if !decision.predictions.isEmpty {
                    draw("Predictions", font: .systemFont(ofSize: 12, weight: .semibold), spacingAfter: 4)
                    for p in decision.predictions {
                        draw("• [\(p.probabilityPercent)%] \(p.title) — \(p.status.rawValue)",
                             font: .systemFont(ofSize: 11), color: .darkGray)
                    }
                    cursorY += 4
                }

                if let review = decision.outcomeReview {
                    draw("Outcome review", font: .systemFont(ofSize: 12, weight: .semibold), spacingAfter: 4)
                    draw("What happened: \(review.whatHappened)", font: .systemFont(ofSize: 11), color: .darkGray)
                    draw("Outcome quality: \(review.outcomeQuality)/5 · Decision quality: \(review.decisionQuality)/5 · Would do again: \(review.wouldDoAgain ? "Yes" : "No")",
                         font: .systemFont(ofSize: 10), color: .gray)
                    if !review.mainLesson.isEmpty {
                        draw("Lesson: \(review.mainLesson)", font: .systemFont(ofSize: 11, weight: .medium), color: .black)
                    }
                }

                divider()
            }
        }

        return url
    }

    private static func fileTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.string(from: Date())
    }
}
