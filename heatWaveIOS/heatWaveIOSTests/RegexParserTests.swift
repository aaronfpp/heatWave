// RegexParserTests.swift
// heatWaveIOSTests
//
// XCTest coverage for RegexParser.

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
        let result = parser.parseEventHeader(line: "Event 1 Girls 10 & Under 200 Yard Freestyle")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.number, 1)
        XCTAssertEqual(result?.gender, .female)
        XCTAssertEqual(result?.distance, 200)
        XCTAssertEqual(result?.stroke, "Freestyle")
        XCTAssertEqual(result?.name, "10 & Under 200 Freestyle")
    }

    func testEventHeaderWithColonSuffix() throws {
        // "Event 2: Boys 10 & Under 200 Yard Freestyle"
        let result = parser.parseEventHeader(line: "Event 2: Boys 10 & Under 200 Yard Freestyle")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.number, 2)
        XCTAssertEqual(result?.gender, .male)
    }

    func testContinuationEventHeaderIsIgnored() throws {
        // "Event 4 ...(Boys 12 & Under 100 LC Meter Freestyle)"
        let result = parser.parseEventHeader(line: "Event 4 ...(Boys 12 & Under 100 LC Meter Freestyle)")
        XCTAssertNil(result, "Continuation headers should be ignored")
    }

    func testCollegiateEventHeader() throws {
        // "Event 12 Women 200 Yard Backstroke"
        let result = parser.parseEventHeader(line: "Event 12 Women 200 Yard Backstroke")
        XCTAssertNotNil(result)
        // Per USA Swimming rules and our constraints, even = male, ignoring "Women"
        XCTAssertEqual(result?.gender, .male)
        XCTAssertEqual(result?.distance, 200)
        XCTAssertEqual(result?.stroke, "Backstroke")
        XCTAssertEqual(result?.name, "200 Backstroke")
    }

    func testNonHeaderLineReturnsNil() throws {
        // "1 Smith, John 14 Tulsa Swim-OK 2:41.23" → parseEventHeader → nil
        let result = parser.parseEventHeader(line: "1 Smith, John 14 Tulsa Swim-OK 2:41.23")
        XCTAssertNil(result, "Non-header line should not parse as an event header")
    }

    // MARK: - Individual Entry Parsing

    func testStandardIndividualEntry() throws {
        // "1 Mitchell, Braylin R 12 SSC-OK 1:03.39"
        let result = parser.parseIndividualEntry(line: "1 Mitchell, Braylin R 12 SSC-OK 1:03.39")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.place, 1)
        XCTAssertEqual(result?.swimmer.name, "Mitchell, Braylin R")
        XCTAssertEqual(result?.swimmer.age, "12")
        XCTAssertEqual(result?.swimmer.teamCode, "SSC-OK")
        XCTAssertEqual(result?.seedTime, 63.39) // 1*60 + 3.39
    }

    func testCollegiateEntryWithYearCode() throws {
        // "1 Cox, Jillian SO Texas QS 15:32.75"
        let result = parser.parseIndividualEntry(line: "1 Cox, Jillian SO Texas QS 15:32.75")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.swimmer.age, "SO")
        XCTAssertEqual(result?.swimmer.teamCode, "Texas")
        XCTAssertEqual(result?.seedTime, 932.75) // 15*60 + 32.75
    }

    func testEntryWithNT() throws {
        // "8 Jones, Bob 12 Tulsa Swim-OK NT"
        let result = parser.parseIndividualEntry(line: "8 Jones, Bob 12 Tulsa Swim-OK NT")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.seedTime, TimeInterval.infinity)
    }

    func testEntryWithStandardCode() throws {
        // "2 Smith, Anna 15 Club Team A 1:05.44"
        let result = parser.parseIndividualEntry(line: "2 Smith, Anna 15 Club Team A 1:05.44")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.swimmer.teamCode, "Club Team")
        XCTAssertEqual(result?.seedTime, 65.44)
    }

    // MARK: - Relay Entry Parsing

    func testStandardRelayEntry() throws {
        // "1 KMS-OK A 2:12.03"
        let result = parser.parseRelayEntry(line: "1 KMS-OK A 2:12.03")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.place, 1)
        XCTAssertEqual(result?.teamName, "KMS-OK A")
        XCTAssertEqual(result?.seedTime, 132.03) // 2*60 + 12.03
    }

    func testRelayEntryWithNT() throws {
        // "12 ST-OK A NT"
        let result = parser.parseRelayEntry(line: "12 ST-OK A NT")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.teamName, "ST-OK A")
        XCTAssertEqual(result?.seedTime, TimeInterval.infinity)
    }

    // MARK: - Seed Time Normalisation

    func testNTNormalisesCorrectly() throws {
        XCTAssertEqual(parser.parseSeedTime("NT"), TimeInterval.infinity)
    }

    func testPartialTimeGetsDecimalAppended() throws {
        XCTAssertEqual(parser.parseSeedTime("2:41"), 161.0)
    }
    
    func testSecondsTimeGetsParsed() throws {
        XCTAssertEqual(parser.parseSeedTime("28.50"), 28.50)
    }

    // MARK: - Skip Line Detection

    func testSkipLinesAreIgnored() throws {
        XCTAssertTrue(parser.isSkipLine("Name Age Team Seed Time"))
        XCTAssertTrue(parser.isSkipLine("Team Relay Seed Time"))
        XCTAssertTrue(parser.isSkipLine("King Marlin Swim Club HY-TEK's MEET MANAGER..."))
        XCTAssertFalse(parser.isSkipLine("1 Mitchell, Braylin R 12 SSC-OK 1:03.39"))
    }

    // MARK: - Full Text Parse Integration

    func testParsesMultipleEventsInOrder() throws {
        let text = """
        Event 1 Girls 10 & Under 200 Yard Freestyle
        Name Age Team Seed Time
        1 Meek, Keaston 10 Bartlesville Spl-OK 2:42.05
        2 Smith, Anna 10 Club Team 2:45.00
        
        Event 2 Boys 10 & Under 200 Yard Freestyle
        Name Age Team Seed Time
        1 Jones, Bob 10 Tulsa Swim-OK NT
        
        Event 3 Girls 11-12 200 Yard Freestyle Relay
        Team Relay Seed
        1 King Marlin Swim-OK A 2:13.43
        """
        
        let events = try parser.parseEvents(from: text)
        XCTAssertEqual(events.count, 3)
        
        let event1 = events[0]
        XCTAssertEqual(event1.number, 1)
        XCTAssertFalse(event1.isRelay)
        XCTAssertEqual(event1.entries.count, 2)
        if case .individual(let e1) = event1.entries[0] {
            XCTAssertEqual(e1.swimmer.name, "Meek, Keaston")
        } else { XCTFail() }
        
        let event2 = events[1]
        XCTAssertEqual(event2.number, 2)
        XCTAssertEqual(event2.entries.count, 1)
        if case .individual(let e2) = event2.entries[0] {
            XCTAssertEqual(e2.seedTime, TimeInterval.infinity)
        } else { XCTFail() }
        
        let event3 = events[2]
        XCTAssertEqual(event3.number, 3)
        XCTAssertTrue(event3.isRelay)
        XCTAssertEqual(event3.entries.count, 1)
        if case .relay(let r1) = event3.entries[0] {
            XCTAssertEqual(r1.teamName, "King Marlin Swim-OK A")
            XCTAssertEqual(r1.seedTime, 133.43)
        } else { XCTFail() }
    }
}
