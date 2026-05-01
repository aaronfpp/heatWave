// SeedingEngine.swift
// heatWaveIOS
//
// Applies USA Swimming preliminary seeding rules to a list of parsed events,
// producing heat and lane assignments for the PDF generator.
//
// PORTING NOTES — read before implementing:
//
//  Source of truth: src/seeding/seeder.py
//
//  Core rules (from Python source):
//
//    1. SORT entries by seed time — slowest to fastest.
//       NT (no time) sorts LAST (after all timed entries).
//
//    2. CALCULATE heats: ceil(entryCount / laneCount)
//
//    3. FILL heats from slowest to fastest.
//       If entry count is not evenly divisible by lane count, the FIRST heat
//       is a partial heat (the "incomplete" heat). Other heats are full.
//
//    4. ASSIGN lanes CENTER-OUT within each heat.
//       The fastest swimmer in the heat gets the center lane.
//       Alternate left-right outward from center.
//
//       For 8 lanes: [4, 5, 3, 6, 2, 7, 1, 8]
//       For 6 lanes: [3, 4, 2, 5, 1, 6]
//
//    5. SORT final assignments by (heat, lane) for output.
//
//  Python reference: src/seeding/seeder.py  seed_event(), get_center_out_lanes()
//  Minimum iOS: 16.0

import Foundation

// MARK: - Output Models

struct LaneAssignment {
    let entry: EventEntry
    let heat: Int
    let lane: Int
}

struct HeatSheet {
    let event: ParsedEvent
    let lanes: Int
    let heats: Int
    let assignments: [LaneAssignment]   // sorted by (heat, lane)
}

// MARK: - SeedingEngine

/// Converts parsed events into lane-assigned heat sheets using USA Swimming rules.
struct SeedingEngine {

    // MARK: - Configuration

    /// Default lane count. Can be overridden (e.g. 6-lane pool).
    var defaultLaneCount: Int = 8

    // MARK: - Public API

    /// Seeds a single event and returns a complete HeatSheet.
    ///
    /// - Parameters:
    ///   - event: A `ParsedEvent` with all entries populated.
    ///   - lanes: Number of lanes in the pool (default: 8).
    /// - Returns: A `HeatSheet` with heat/lane assignments sorted by (heat, lane).
    func seed(event: ParsedEvent, lanes: Int? = nil) -> HeatSheet {
        // TODO Phase 4: port seed_event() from seeder.py
        //
        // Implementation sketch:
        //   1. let laneCount = lanes ?? defaultLaneCount
        //   2. let sorted = sortByTime(event.entries)
        //   3. let numHeats = Int(ceil(Double(sorted.count) / Double(laneCount)))
        //   4. let pattern = centerOutPattern(lanes: laneCount)
        //   5. loop heats, slice entries, reverse, assign lanes via pattern
        //   6. sort assignments by (heat, lane)
        //   7. return HeatSheet(...)
        fatalError("SeedingEngine.seed(event:lanes:) not yet implemented — Phase 4")
    }

    /// Seeds all events in a psych sheet in document order.
    ///
    /// - Parameters:
    ///   - events: Array of `ParsedEvent` objects from RegexParser.
    ///   - lanes: Number of lanes (applied to all events).
    /// - Returns: Array of `HeatSheet` objects in event order.
    func seedAll(events: [ParsedEvent], lanes: Int? = nil) -> [HeatSheet] {
        // TODO Phase 4: map seed(event:lanes:) over events
        fatalError("SeedingEngine.seedAll(events:lanes:) not yet implemented — Phase 4")
    }

    // MARK: - Internal Helpers (stubbed; implement in Phase 4)

    /// Converts a seed time string to seconds for sorting.
    /// NT → Double.infinity (sorts last, after all timed entries).
    ///
    /// - Parameter timeString: "MM:SS.XX" or "NT"
    func timeToSeconds(_ timeString: String) -> Double {
        // TODO Phase 4: port time_to_seconds() from seeder.py
        fatalError("timeToSeconds not yet implemented — Phase 4")
    }

    /// Returns entries sorted slowest-first (NT at the very end).
    ///
    /// - Parameter entries: Unsorted event entries.
    func sortByTime(_ entries: [EventEntry]) -> [EventEntry] {
        // TODO Phase 4: sort by timeToSeconds, reverse=true for slowest-first
        fatalError("sortByTime not yet implemented — Phase 4")
    }

    /// Generates the center-out lane assignment pattern for a given lane count.
    ///
    /// For 8 lanes: [4, 5, 3, 6, 2, 7, 1, 8]
    /// For 6 lanes: [3, 4, 2, 5, 1, 6]
    ///
    /// - Parameter lanes: Number of lanes in the pool.
    /// - Returns: Lane numbers in center-out placement order (position 0 = fastest in heat).
    func centerOutPattern(lanes: Int) -> [Int] {
        // TODO Phase 4: port get_center_out_lanes() from seeder.py
        fatalError("centerOutPattern not yet implemented — Phase 4")
    }
}
