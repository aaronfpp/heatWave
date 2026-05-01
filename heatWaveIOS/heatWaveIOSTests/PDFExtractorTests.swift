// PDFExtractorTests.swift
// heatWaveIOSTests
//
// XCTest coverage for PDFExtractor.
// Required: at least one test per documented behaviour before Phase 2 ships.
//
// Test targets to cover (per product constraints):
//   1. Single-column PDF → text extracted without duplication
//   2. Two-column PDF    → columns merged in left-then-right order
//   3. Scanned PDF       → throws PDFExtractionError.scannedPDF
//   4. Zero-page PDF     → throws PDFExtractionError.emptyDocument
//   5. Bad URL           → throws PDFExtractionError.unreadableFile

import XCTest
@testable import heatWaveIOS

final class PDFExtractorTests: XCTestCase {

    // MARK: - System Under Test

    var extractor: PDFExtractor!

    override func setUp() {
        super.setUp()
        extractor = PDFExtractor()
    }

    // MARK: - Column Merging

    func testTwoColumnMergeOrder() throws {
        // TODO Phase 2:
        // Given a synthetic two-column PDF (programmatically generated in the test)
        // where the left column contains "LEFT" and the right contains "RIGHT",
        // the extracted text should contain "LEFT" before "RIGHT".
        //
        // let pdf = makeSyntheticTwoColumnPDF(left: "LEFT\n", right: "RIGHT\n")
        // let text = try extractor.extractText(from: pdf)
        // XCTAssertTrue(text.range(of: "LEFT")! < text.range(of: "RIGHT")!)
        XCTFail("testTwoColumnMergeOrder not yet implemented — Phase 2")
    }

    func testColumnSplitRatioIsRespected() throws {
        // TODO Phase 2:
        // When columnSplitRatio is changed from 0.5 to 0.4,
        // verify a wider left rect is used and text is still extracted without crash.
        XCTFail("testColumnSplitRatioIsRespected not yet implemented — Phase 2")
    }

    // MARK: - Scanned PDF Guard

    func testScannedPDFThrowsCorrectError() throws {
        // TODO Phase 2:
        // Given a PDF that contains only images (no text layer),
        // extractText should throw PDFExtractionError.scannedPDF.
        //
        // let scannedURL = Bundle(for: type(of: self)).url(forResource: "scanned_sample", withExtension: "pdf")!
        // XCTAssertThrowsError(try extractor.extractText(from: scannedURL)) { error in
        //     XCTAssertEqual(error as? PDFExtractionError, .scannedPDF)
        // }
        XCTFail("testScannedPDFThrowsCorrectError not yet implemented — Phase 2")
    }

    func testScannedPDFErrorMessageMatchesRequirement() throws {
        // TODO Phase 2:
        // The errorDescription of .scannedPDF must exactly equal the required string.
        let error = PDFExtractionError.scannedPDF
        XCTAssertEqual(
            error.errorDescription,
            "This PDF appears to be image-based. Scanned PDFs are not yet supported."
        )
        // NOTE: This test does NOT require Phase 2 implementation — it validates the
        // error string constant right now. Remove XCTFail when PDFExtractor is wired.
    }

    // MARK: - Edge Cases

    func testEmptyDocumentThrowsError() throws {
        // TODO Phase 2:
        // A zero-page PDF should throw PDFExtractionError.emptyDocument.
        XCTFail("testEmptyDocumentThrowsError not yet implemented — Phase 2")
    }

    func testUnreadableURLThrowsError() throws {
        // TODO Phase 2:
        // A URL pointing to a nonexistent file should throw .unreadableFile.
        XCTFail("testUnreadableURLThrowsError not yet implemented — Phase 2")
    }

    // MARK: - isLikelyScanned Heuristic

    func testIsLikelyScannedReturnsTrueForShortText() throws {
        // TODO Phase 2:
        // When the first 3 pages total fewer than 100 characters, isLikelyScanned
        // should return true.
        XCTFail("testIsLikelyScannedReturnsTrueForShortText not yet implemented — Phase 2")
    }

    func testIsLikelyScannedReturnsFalseForNormalPDF() throws {
        // TODO Phase 2:
        // When a real psych sheet PDF is loaded, isLikelyScanned should return false.
        XCTFail("testIsLikelyScannedReturnsFalseForNormalPDF not yet implemented — Phase 2")
    }
}
