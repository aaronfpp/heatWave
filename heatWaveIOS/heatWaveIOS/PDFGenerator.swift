// PDFGenerator.swift
// heatWaveIOS
//
// Renders a complete heat sheet (array of HeatSheet objects from SeedingEngine)
// into a formatted PDF file on-device, saved to the user's document directory.
//
// DESIGN NOTES:
//
//  • Uses UIGraphicsPDFRenderer (UIKit) — the simplest iOS API for multi-page
//    PDF generation. Does NOT require PDFKit at generation time.
//
//  • Output path: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    The generated file is named with a timestamp so repeated runs don't overwrite:
//    "HeatSheet_<ISO8601timestamp>.pdf"
//
//  • Page layout mirrors the Python output format from seeder.py format_heat_sheet():
//      Header:   "Event <N>: <Gender> <Distance>Y <Stroke>"
//      Sub:      "Total Heats: <N> | Total Entries: <N>"
//      Per heat: "Heat <N>:" with ruled separator
//      Per lane: "Lane <N>: <Name> (Age <age>) <team> - <time>"
//                "Lane <N>: <TeamName> - <time>"  (relay)
//
//  • Page size: US Letter (612 × 792 pts) to match the Python PDF output.
//
//  • Typography: System font. No custom fonts needed for MVP.
//    Use UIFont.systemFont(ofSize:) and UIFont.boldSystemFont(ofSize:).
//
//  • A new page is started when the remaining vertical space on the current
//    page is insufficient for the next heat block.
//
//  Python reference: src/seeding/seeder.py  format_heat_sheet()
//  Minimum iOS: 16.0

import UIKit
import Foundation

// MARK: - PDFGeneratorError

enum PDFGeneratorError: LocalizedError {
    case noHeatSheets
    case fileWriteFailed(path: String)

    var errorDescription: String? {
        switch self {
        case .noHeatSheets:
            return "No heat sheets to generate."
        case .fileWriteFailed(let path):
            return "Failed to write the PDF to: \(path)"
        }
    }
}

// MARK: - PDFGenerator

/// Renders an array of `HeatSheet` objects into a formatted PDF file.
struct PDFGenerator {

    // MARK: - Configuration

    /// Page size in points. Default: US Letter (8.5 × 11 in).
    var pageSize: CGSize = CGSize(width: 612, height: 792)

    /// Inset from page edges for all content.
    var margin: CGFloat = 36

    // MARK: - Public API

    /// Renders `heatSheets` into a PDF and saves it to `.documentDirectory`.
    ///
    /// - Parameter heatSheets: Ordered array of `HeatSheet` from SeedingEngine.
    /// - Returns: The URL of the saved PDF file.
    /// - Throws: `PDFGeneratorError` if no heat sheets are provided or writing fails.
    func generate(heatSheets: [HeatSheet]) throws -> URL {
        // TODO Phase 4: implement using UIGraphicsPDFRenderer
        //
        // Implementation sketch:
        //   1. guard !heatSheets.isEmpty else { throw .noHeatSheets }
        //   2. let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        //   3. let data = renderer.pdfData { context in
        //        context.beginPage()
        //        var cursor: CGFloat = margin
        //        for sheet in heatSheets {
        //            drawEventHeader(sheet, context: context, cursor: &cursor)
        //            for assignment grouped by heat {
        //                if cursor + estimatedHeatHeight > pageSize.height - margin {
        //                    context.beginPage(); cursor = margin
        //                }
        //                drawHeat(assignments, context: context, cursor: &cursor)
        //            }
        //        }
        //   }
        //   4. let url = outputURL()
        //   5. try data.write(to: url)
        //   6. return url
        fatalError("PDFGenerator.generate(heatSheets:) not yet implemented — Phase 4")
    }

    // MARK: - Internal Helpers (stubbed; implement in Phase 4)

    /// Draws the event header block onto the current PDF page.
    /// Mirrors format_heat_sheet() lines 166-168 in seeder.py.
    private func drawEventHeader(_ sheet: HeatSheet,
                                 context: UIGraphicsPDFRendererContext,
                                 cursor: inout CGFloat) {
        // TODO Phase 4
        fatalError("drawEventHeader not yet implemented — Phase 4")
    }

    /// Draws one heat's lane assignments onto the current PDF page.
    /// Mirrors format_heat_sheet() lines 172-185 in seeder.py.
    private func drawHeat(_ assignments: [LaneAssignment],
                          heatNumber: Int,
                          context: UIGraphicsPDFRendererContext,
                          cursor: inout CGFloat) {
        // TODO Phase 4
        fatalError("drawHeat not yet implemented — Phase 4")
    }

    /// Returns a timestamped output URL in the app's document directory.
    /// Example: "HeatSheet_2026-05-01T21-00-00.pdf"
    private func outputURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = ISO8601DateFormatter()
        let stamp = formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
        return docs.appendingPathComponent("HeatSheet_\(stamp).pdf")
    }
}
