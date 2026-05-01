// RegexParserTests.swift
// heatWaveIOSTests
//
// XCTest coverage for RegexParser.
// Test cases are derived directly from the Python unit test corpus and
// the example strings documented in extractor.py.

import XCTest
@testable import heatWaveIOS

final class RegexParserTests: XCTestCase {

    var parser: RegexParser!

    override func setUp() {
        super.setUp()
        parser = RegexParser()
    }

    // MARK: - Event Header Parsing

    func testStandardEventHeader() throws {
        // "Event 1 Girls 10 & Under 200 Yard Freestyle"
        // → number: 1, gender: "Girls", distance: 200, stroke: "Freestyle"
        XCTFail("testStandardEventHeader not yet implemented — Phase 3")
    }

    func testEventHeaderWithColonSuffix() throws {
        // "Event 1: Girls 10 & Under 200 Yard Freestyle"
        // Should parse identically to the colon-free form.
        XCTFail("testEventHeaderWithColonSuffix not yet implemented — Phase 3")
    }

    func testContinuationEventHeader() throws {
        // "Event 5 ...(Girls 10 & Under 200 Yard Freestyle)"
        // Should produce the same ParsedEvent as the original header.
        XCTFail("testContinuationEventHeader not yet implemented — Phase 3")
    }

    func testCollegiateEventHeader() throws {
        // "Event 12 Women 200 Yard Backstroke"
        // gender: "Women", no age group
        XCTFail("testCollegiateEventHeader not yet implemented — Phase 3")
    }

    func testNonHeaderLineReturnsNil() throws {
        // "1 Smith, John 14 Tulsa Swim-OK 2:41.23" → parseEventHeader → nil
        let result = parser.parseEventHeader(line: "1 Smith, John 14 Tulsa Swim-OK 2:41.23")
        XCTAssertNil(result, "Non-header line should not parse as an event header")
        // NOTE: This test exercises the nil-return path. Remove XCTFail once implemented.
        XCTFail("Unimplemented — Phase 3")
    }

    // MARK: - Individual Entry Parsing

    func testStandardIndividualEntry() throws {
        // "1 Meek, Keaston 10 Bartlesville Spl-OK 2:42.05"
        // → place: 1, name: "Meek, Keaston", age: "10", team: "Bartlesville Spl-OK", time: "2:42.05"
        XCTFail("testStandardIndividualEntry not yet implemented — Phase 3")
    }

    func testCollegiateEntryWithYearCode() throws {
        // "1 Cox, Jillian SO Texas QS 15:32.75"
        // → age: "SO", std code "QS" excluded from team, time: "15:32.75"
        XCTFail("testCollegiateEntryWithYearCode not yet implemented — Phase 3")
    }

    func testEntryWithNT() throws {
        // "8 Jones, Bob 12 Tulsa Swim-OK NT"
        // → seedTime: "NT"
        XCTFail("testEntryWithNT not yet implemented — Phase 3")
    }

    func testEntryWithStandardCode() throws {
        // "2 Smith, Anna 15 Club Team A 1:05.44"
        // A standard code "A" should not be included in the team code
        XCTFail("testEntryWithStandardCode not yet implemented — Phase 3")
    }

    // MARK: - Relay Entry Parsing

    func testStandardRelayEntry() throws {
        // "1 King Marlin Swim-OK A 2:13.43"
        // → place: 1, teamName: "King Marlin Swim-OK A", time: "2:13.43"
        XCTFail("testStandardRelayEntry not yet implemented — Phase 3")
    }

    func testRelayEntryWithNT() throws {
        // "3 Tulsa Aquatics NT"
        XCTFail("testRelayEntryWithNT not yet implemented — Phase 3")
    }

    // MARK: - Seed Time Normalisation

    func testNTNormalisesCorrectly() throws {
        XCTFail("testNTNormalisesCorrectly not yet implemented — Phase 3")
    }

    func testPartialTimeGetsDecimalAppended() throws {
        // "2:41" → "2:41.00"
        XCTFail("testPartialTimeGetsDecimalAppended not yet implemented — Phase 3")
    }

    // MARK: - Skip Line Detection

    func testSkipLinesAreIgnored() throws {
        // Lines containing "Name Age Team", "HY-TEK", etc. should return true
        XCTFail("testSkipLinesAreIgnored not yet implemented — Phase 3")
    }

    // MARK: - Full Text Parse Integration

    func testParsesMultipleEventsInOrder() throws {
        // Given a multi-event psych sheet text string,
        // parse() should return events in document order with correct entry counts.
        XCTFail("testParsesMultipleEventsInOrder not yet implemented — Phase 3")
    }
}
