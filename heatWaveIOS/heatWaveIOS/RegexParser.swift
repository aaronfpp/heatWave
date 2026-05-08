// RegexParser.swift
// heatWaveIOS
//
// Parses the plain-text output of PDFExtractor into structured Swift data models.

import Foundation

/// Parses psych sheet plain text into an array of Event models.
struct RegexParser {

    // MARK: - Public API

    /// Main entry point. Takes the full merged column text from PDFExtractor
    /// and returns all parsed events with their entries.
    ///
    /// - Parameter text: Plain text string from PDFExtractor.extractText(from:)
    /// - Returns: Array of Event objects in document order.
    func parseEvents(from text: String) throws -> [Event] {
        print("=== RAW TEXT FIRST 500 CHARS ===")
        print(String(text.prefix(500)))
        print("=== END RAW TEXT ===")
        
        var events: [Event] = []
        var currentEvent: Event?
        
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            // Skip known header lines
            if isSkipLine(trimmed) { continue }
            
            // Try parsing event header
            if let header = parseEventHeader(line: trimmed) {
                // If it's a continuation of the current event, ignore the new header
                if let current = currentEvent, current.number == header.number {
                    continue
                }
                
                if let current = currentEvent {
                    events.append(current)
                }
                currentEvent = header
                continue
            }
            
            // Parse entries
            if var event = currentEvent {
                if event.isRelay {
                    if let relayEntry = parseRelayEntry(line: trimmed) {
                        event.entries.append(.relay(relayEntry))
                        currentEvent = event
                    }
                } else {
                    if let indEntry = parseIndividualEntry(line: trimmed) {
                        event.entries.append(.individual(indEntry))
                        currentEvent = event
                    }
                }
            }
        }
        
        if let current = currentEvent {
            events.append(current)
        }
        
        print("=== PARSE RESULT: \(events.count) events ===")
        for e in events {
            print("Event \(e.number): \(e.entries.count) entries")
        }
        
        return events
    }

    // MARK: - Internal Parsers

    /// Parses a single event header line.
    func parseEventHeader(line: String) -> Event? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 3, parts[0].uppercased() == "EVENT" else { return nil }
        
        let eventNumStr = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: ":"))
        guard let eventNum = Int(eventNumStr) else { return nil }
        
        let genders = ["GIRLS", "BOYS", "WOMEN", "MEN"]
        var genderIdx = -1
        for (i, part) in parts.enumerated() {
            if i >= 2 && genders.contains(part.uppercased()) {
                genderIdx = i
                break
            }
        }
        if genderIdx == -1 { return nil }
        
        let commonDistances = [25, 50, 100, 200, 400, 500, 800, 1000, 1500, 1650]
        var distance = 0
        var distanceIdx = -1
        
        // Search backwards from the end to find the distance
        for i in stride(from: parts.count - 1, to: genderIdx, by: -1) {
            if let val = Int(parts[i]) {
                var isDist = commonDistances.contains(val)
                if !isDist {
                    let window = (i+1..<min(i+4, parts.count)).map { parts[$0].uppercased() }
                    if window.contains(where: { ["YARD","YARDS","LC","SC","METER","METERS","Y","M"].contains($0) }) {
                        isDist = true
                    }
                }
                if isDist {
                    distance = val
                    distanceIdx = i
                    break
                }
            }
        }
        
        // Fallback to last number if no common distance found
        if distance == 0 {
            for i in stride(from: parts.count - 1, to: genderIdx, by: -1) {
                if let val = Int(parts[i]) {
                    distance = val
                    distanceIdx = i
                    break
                }
            }
        }
        
        if distance == 0 { return nil }
        
        var strokeParts: [String] = []
        for i in (distanceIdx + 1)..<parts.count {
            let p = parts[i]
            if ["YARD", "YARDS", "METER", "METERS", "LC", "SC", "LCM", "SCY", "SCM"].contains(p.uppercased()) { continue }
            strokeParts.append(p)
        }
        let stroke = strokeParts.joined(separator: " ")
        
        var ageGroup = ""
        if distanceIdx > genderIdx + 1 {
            ageGroup = parts[(genderIdx + 1)..<distanceIdx].joined(separator: " ")
        }
        
        var eventName = "\(ageGroup) \(distance) \(stroke)".trimmingCharacters(in: .whitespaces)
        if ageGroup.isEmpty {
            eventName = "\(distance) \(stroke)"
        }
        
        let isRelay = eventName.uppercased().contains("RELAY")
        
        return Event(
            number: eventNum,
            name: eventName,
            distance: distance,
            stroke: stroke,
            entries: [],
            isRelay: isRelay
        )
    }

    /// Parses a single individual swimmer entry line.
    func parseIndividualEntry(line: String) -> IndividualEntry? {
        let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 4 else { return nil }
        guard let place = Int(parts[0]) else { return nil }
        
        let seedTimeStr = parts.last!
        let seedTimePattern = #/^[Xx]?\d+/#
        guard seedTimeStr.uppercased().hasPrefix("NT") || seedTimeStr.firstMatch(of: seedTimePattern) != nil else { return nil }
        
        let seedTime = parseSeedTime(seedTimeStr)
        
        var hasStd = false
        if parts.count >= 6 {
            let potentialStd = parts[parts.count - 2].uppercased()
            let stdRegex = #/^[A-Z]{1,3}$/#
            if potentialStd.firstMatch(of: stdRegex) != nil && !["SO", "FR", "JR", "SR"].contains(potentialStd) {
                hasStd = true
            }
        }
        
        var ageIdx = -1
        let searchStart = hasStd ? parts.count - 3 : parts.count - 2
        
        for i in stride(from: searchStart, through: 1, by: -1) {
            let partUpper = parts[i].uppercased()
            if partUpper.firstMatch(of: #/^\d{1,2}$/#) != nil || partUpper.firstMatch(of: #/^(SO|FR|JR|SR)$/#) != nil {
                ageIdx = i
                break
            }
        }
        
        if ageIdx == -1 { return nil }
        
        let name = parts[1..<ageIdx].joined(separator: " ")
        let age = parts[ageIdx]
        
        let teamEnd = hasStd ? parts.count - 2 : parts.count - 1
        let teamCode = parts[(ageIdx + 1)..<teamEnd].joined(separator: " ")
        
        let swimmer = Swimmer(name: name, age: age, teamCode: teamCode)
        return IndividualEntry(place: place, swimmer: swimmer, seedTime: seedTime)
    }

    /// Parses a single relay team entry line.
    func parseRelayEntry(line: String) -> RelayEntry? {
        let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 3 else { return nil }
        guard let place = Int(parts[0]) else { return nil }
        
        let seedTimeStr = parts.last!
        let timeRegex = #/^[Xx]?\d+:\d{2}/#
        let secRegex = #/^[Xx]?\d{1,2}\.\d{2}/#
        guard seedTimeStr.uppercased().hasPrefix("NT") || 
              seedTimeStr.firstMatch(of: timeRegex) != nil || 
              seedTimeStr.firstMatch(of: secRegex) != nil else { return nil }
        
        let teamName = parts[1..<(parts.count - 1)].joined(separator: " ")
        let seedTime = parseSeedTime(seedTimeStr)
        
        return RelayEntry(place: place, teamName: teamName, seedTime: seedTime)
    }

    /// Normalises a seed time string to TimeInterval.
    func parseSeedTime(_ raw: String) -> TimeInterval {
        var trimmed = raw.trimmingCharacters(in: .whitespaces).uppercased()
        
        // Remove trailing course indicators (Y, L, S) or standard flags (e.g. B for bonus)
        if trimmed.hasSuffix("Y") || trimmed.hasSuffix("L") || trimmed.hasSuffix("S") || trimmed.hasSuffix("B") {
            trimmed.removeLast()
        }
        
        // Remove exhibition "X" prefix
        if trimmed.hasPrefix("X") {
            trimmed.removeFirst()
        }
        
        if trimmed.hasPrefix("NT") {
            return TimeInterval.infinity
        }
        
        // MM:SS.XX
        if let match = trimmed.firstMatch(of: #/^(\d+):(\d{2})\.(\d{2})$/#) {
            let min = Double(match.1) ?? 0
            let sec = Double(match.2) ?? 0
            let frac = Double(match.3) ?? 0
            return (min * 60) + sec + (frac / 100)
        }
        
        // MM:SS
        if let match = trimmed.firstMatch(of: #/^(\d+):(\d{2})$/#) {
            let min = Double(match.1) ?? 0
            let sec = Double(match.2) ?? 0
            return (min * 60) + sec
        }
        
        // SS.XX
        if let match = trimmed.firstMatch(of: #/^(\d{1,2})\.(\d{2})$/#) {
            let sec = Double(match.1) ?? 0
            let frac = Double(match.2) ?? 0
            return sec + (frac / 100)
        }
        
        return TimeInterval.infinity
    }

    // MARK: - Skip Line Check

    func isSkipLine(_ line: String) -> Bool {
        // Skip continuation headers completely
        if line.hasPrefix("Event ") && line.contains("...") {
            return true
        }
        
        let skips = [
            "Name Age Team Seed Time", 
            "Name Age Team", 
            "Team Relay Seed Time", 
            "Team Relay Seed", 
            "Seed Time", 
            "HY-TEK", 
            "Elig. Year", 
            "Std Seed",
            "King Marlin Swim Club",
            "Psych Sheet",
            "KMSC Spring Twister",
            "King Marlin Spring Twister"
        ]
        return skips.contains(where: { line.contains($0) })
    }
}
