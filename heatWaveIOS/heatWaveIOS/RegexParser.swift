// RegexParser.swift
// heatWaveIOS
//
// Parses the plain-text output of PDFExtractor into structured Swift data models.
//
// PORTING NOTES — read before implementing:
//
//  Source of truth: src/parser/extractor.py
//  Do NOT transliterate Python line-for-line. Instead port the INTENT:
//
//    parse_event_header()    → EventHeader.parse(line:)
//    parse_individual_entry() → IndividualEntry.parse(line:)
//    parse_relay_entry()      → RelayEntry.parse(line:)
//    parse_events_from_text() → RegexParser.parse(text:)
//
//  Uses Swift's native Regex (iOS 16+) — NOT NSRegularExpression.
//
//  Key parsing rules (from Python source):
//
//    EVENT HEADER
//      Pattern:  "Event <N> <Gender> <AgeGroup> <Distance> [Yard|Meter] <Stroke>"
//      Also:     "Event <N> ...(<inner content>)" — continuation header
//      Genders:  GIRLS | BOYS | WOMEN | MEN
//      Distances: 25 | 50 | 100 | 200 | 400 | 500 | 800 | 1000 | 1500 | 1650
//
//    INDIVIDUAL ENTRY
//      Pattern:  "<Place> <LastName, FirstName> <Age|Year> <TeamCode> [<Std>] <SeedTime>"
//      Age/Year: 1-2 digit number OR SO|FR|JR|SR
//      Std code: 1-3 uppercase letters, NOT a year code
//      SeedTime: MM:SS.XX or NT
//
//    RELAY ENTRY
//      Pattern:  "<Place> <TeamName...> <SeedTime>"
//      SeedTime: must start with digits (MM:SS...) or be "NT"
//
//    SKIP LINES containing:
//      "Name Age Team", "Team Relay Seed", "Seed Time", "HY-TEK",
//      "Elig. Year", "Std Seed"
//
//  Python reference: src/parser/extractor.py
//  Minimum iOS: 16.0 (Swift Regex)

import Foundation

// MARK: - Data Models
// These mirror src/models/schemas.py exactly.

struct Swimmer {
    let name: String
    let age: String?        // nil for relay; "SO"/"FR"/etc. for collegiate
    let teamCode: String
}

struct IndividualEntry {
    let place: Int
    let swimmer: Swimmer
    let seedTime: String
}

struct RelayEntry {
    let place: Int
    let teamName: String
    let seedTime: String
}

enum EventEntry {
    case individual(IndividualEntry)
    case relay(RelayEntry)
}

struct ParsedEvent {
    let number: Int
    let name: String        // e.g. "10 & Under 200 Freestyle"
    let gender: String      // GIRLS | BOYS | WOMEN | MEN
    let distance: Int       // yards/meters as Int
    let stroke: String      // e.g. "Freestyle"
    var entries: [EventEntry]
    let isRelay: Bool
}

// MARK: - RegexParser

/// Parses psych sheet plain text into an array of ParsedEvent models.
struct RegexParser {

    // MARK: - Public API

    /// Main entry point. Takes the full merged column text from PDFExtractor
    /// and returns all parsed events with their entries.
    ///
    /// - Parameter text: Plain text string from PDFExtractor.extractText(from:)
    /// - Returns: Array of ParsedEvent objects in document order.
    func parse(text: String) -> [ParsedEvent] {
        // TODO Phase 3: implement line-by-line state machine matching Python parse_events_from_text()
        //
        // Implementation sketch:
        //   1. Split text into lines
        //   2. For each line:
        //      a. Try parseEventHeader(line:) → if match, push current event, start new
        //      b. Skip known header lines
        //      c. If in relay event, try parseRelayEntry(line:)
        //      d. Else try parseIndividualEntry(line:)
        //   3. Append last event
        //   4. Return events
        fatalError("RegexParser.parse(text:) not yet implemented — Phase 3")
    }

    // MARK: - Internal Parsers (stubbed; implement in Phase 3)

    /// Parses a single event header line.
    /// - Returns: A `ParsedEvent` template (no entries yet), or `nil` if line is not an event header.
    func parseEventHeader(line: String) -> ParsedEvent? {
        // TODO Phase 3: port parse_event_header() using Swift Regex
        fatalError("parseEventHeader not yet implemented — Phase 3")
    }

    /// Parses a single individual swimmer entry line.
    /// - Returns: An `IndividualEntry`, or `nil` if the line does not match.
    func parseIndividualEntry(line: String) -> IndividualEntry? {
        // TODO Phase 3: port parse_individual_entry() using Swift Regex
        fatalError("parseIndividualEntry not yet implemented — Phase 3")
    }

    /// Parses a single relay team entry line.
    /// - Returns: A `RelayEntry`, or `nil` if the line does not match.
    func parseRelayEntry(line: String) -> RelayEntry? {
        // TODO Phase 3: port parse_relay_entry() using Swift Regex
        fatalError("parseRelayEntry not yet implemented — Phase 3")
    }

    /// Normalises a seed time string to MM:SS.XX or "NT".
    /// - Returns: Normalised seed time string.
    func parseSeedTime(_ raw: String) -> String {
        // TODO Phase 3: port parse_seed_time()
        fatalError("parseSeedTime not yet implemented — Phase 3")
    }

    // MARK: - Skip Line Check

    /// Returns `true` if the line is a known column header that should be ignored.
    func isSkipLine(_ line: String) -> Bool {
        // TODO Phase 3: check against the skip list from Python extractor.py line 292
        fatalError("isSkipLine not yet implemented — Phase 3")
    }
}
