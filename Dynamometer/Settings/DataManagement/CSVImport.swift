/** Requirements:
    - Parse CSV with flexible date formats
    - Support both comma and semicolon separators
    - Handle various column orders (date,value or value,date)
    - Skip header rows and invalid data
*/

import Foundation

struct CSVImport {
    static func parse(text: String) -> [(date: Date, value: Double)] {
        let lines = text.components(separatedBy: .newlines)
        var result: [(Date, Double)] = []
        let dateParsers = makeDateParsers()

        var firstDataSeen = false
        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }

            // Skip header if appears to be non-numeric
            if !firstDataSeen && line.rangeOfCharacter(from: CharacterSet.letters) != nil {
                firstDataSeen = true
                continue
            }
            firstDataSeen = true

            let cols = splitCSV(line)
            guard cols.count >= 2 else { continue }

            let a = cols[0]
            let b = cols[1]

            if let d = parseDate(a, dateParsers), let v = parseDouble(b) {
                result.append((d, v))
            } else if let v = parseDouble(a), let d = parseDate(b, dateParsers) {
                result.append((d, v))
            } else {
                continue
            }
        }
        return result.sorted(by: { $0.0 < $1.0 })
    }

    private static func splitCSV(_ line: String) -> [String] {
        // Simple splitter: comma or semicolon or tab
        let separators = CharacterSet(charactersIn: ",;\t")
        return line.split(whereSeparator: { ch in
            ch.unicodeScalars.contains(where: { separators.contains($0) })
        }).map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private static func parseDouble(_ s: String) -> Double? {
        let normalized = s.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private static func parseDate(_ s: String, _ parsers: [DateFormatter]) -> Date? {
        // ISO8601 fast path
        if let iso = ISO8601DateFormatter().date(from: s) { return iso }
        for df in parsers { if let d = df.date(from: s) { return d } }
        return nil
    }

    private static func makeDateParsers() -> [DateFormatter] {
        let fmts = [
            "yyyy-MM-dd",
            "yyyy/MM/dd",
            "dd.MM.yyyy",
            "MM/dd/yyyy",
            "dd/MM/yyyy"
        ]
        return fmts.map { fmt in
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(secondsFromGMT: 0)
            df.dateFormat = fmt
            return df
        }
    }
}
