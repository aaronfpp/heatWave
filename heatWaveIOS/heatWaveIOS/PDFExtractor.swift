// PDFExtractor.swift
// heatWaveIOS
//
// Responsible for converting a PDF file into a single clean string of text
// that the RegexParser can consume.
//
// DESIGN DECISIONS (see EXTRACTION_SPIKE.md for full rationale):
//
//  • Uses PDFPage.string(for: CGRect) — NOT PDFDocument.string — because
//    psych sheets use a two-column layout. PDFDocument.string interleaves
//    columns; rect-based extraction reads each column independently.
//
//  • Column split: width / 2 (mirrors Python extractor.py line 22-23).
//    Exposed as `columnSplitRatio` for future asymmetric layout support.
//
//  • Scanned PDF guard: if total text across the first 3 pages is < 100
//    characters, the PDF is treated as image-based and an error is thrown.
//    Required user-facing error string:
//    "This PDF appears to be image-based. Scanned PDFs are not yet supported."
//
//  • Output is saved to FileManager.default.urls(for: .documentDirectory, ...)
//    NOT to temporaryDirectory.
//
// Python reference: src/parser/extractor.py  extract_text_from_pdf()
// Minimum iOS: 16.0 (PDFPage.string(for:) availability)

import PDFKit
import Foundation

// MARK: - Error Types

enum PDFExtractionError: LocalizedError {
    /// Thrown when the PDF has no extractable text (likely scanned).
    case scannedPDF
    /// Thrown when the PDFDocument cannot be opened at the given URL.
    case unreadableFile(url: URL)
    /// Thrown when the document has zero pages.
    case emptyDocument

    var errorDescription: String? {
        switch self {
        case .scannedPDF:
            return "This PDF appears to be image-based. Scanned PDFs are not yet supported."
        case .unreadableFile(let url):
            return "Could not open the file: \(url.lastPathComponent)"
        case .emptyDocument:
            return "The selected PDF contains no pages."
        }
    }
}

// MARK: - PDFExtractor

/// Extracts ordered plain text from a two-column USA Swimming psych sheet PDF.
struct PDFExtractor {

    // MARK: - Configuration

    /// Fractional x-position of the column divider (default: 0.5 = centre).
    /// Override for asymmetric layouts (e.g. 0.4 for a 40/60 split).
    var columnSplitRatio: Double = 0.5

    // MARK: - Public API

    /// Opens the PDF at `url`, validates it is text-based, extracts and merges
    /// both columns per page, and returns the full plain text string.
    ///
    /// - Parameter url: File URL to a PDF in the app's sandbox.
    /// - Returns: Merged left+right column text ready for parsing.
    /// - Throws: `PDFExtractionError` if the file cannot be read or is scanned.
    func extractText(from url: URL) throws -> String {
        // TODO Phase 2: implement using PDFPage.string(for: CGRect)
        //
        // Implementation sketch:
        //   1. guard let document = PDFDocument(url: url) else { throw .unreadableFile }
        //   2. guard document.pageCount > 0 else { throw .emptyDocument }
        //   3. if isLikelyScanned(document) { throw .scannedPDF }
        //   4. loop pages → extractTextFromPage(_:) → concat with \n between pages
        //   5. return fullText
        fatalError("PDFExtractor.extractText(from:) not yet implemented — Phase 2")
    }

    // MARK: - Internal Helpers (stubbed; implement in Phase 2)

    /// Returns `true` if the document has fewer than 100 characters across its
    /// first three pages, indicating it is likely a scanned (image-only) PDF.
    ///
    /// - Parameter document: An already-opened `PDFDocument`.
    func isLikelyScanned(_ document: PDFDocument) -> Bool {
        // TODO Phase 2: sample first min(3, pageCount) pages via page.string
        fatalError("isLikelyScanned not yet implemented — Phase 2")
    }

    /// Extracts text from a single page by splitting it into left and right
    /// column rects, extracting each independently, and concatenating them.
    ///
    /// - Parameter page: A `PDFPage` from the document.
    /// - Returns: Left column text + newline + right column text.
    func extractTextFromPage(_ page: PDFPage) -> String {
        // TODO Phase 2:
        //   let bounds = page.bounds(for: .mediaBox)
        //   let leftRect  = CGRect(x: 0, y: 0, width: bounds.width * columnSplitRatio, height: bounds.height)
        //   let rightRect = CGRect(x: bounds.width * columnSplitRatio, y: 0, width: bounds.width * (1 - columnSplitRatio), height: bounds.height)
        //   return (page.string(for: leftRect) ?? "") + "\n" + (page.string(for: rightRect) ?? "")
        fatalError("extractTextFromPage not yet implemented — Phase 2")
    }
}
