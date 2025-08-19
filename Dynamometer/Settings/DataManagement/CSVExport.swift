/** Requirements:
    - Generate CSV with date,value format
    - Use ISO 8601 date format for consistency
    - Include header row for clarity
    - Support SwiftUI document export
*/

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CSVExport {
    static func makeCSV(from readings: [Reading]) -> String {
        var lines: [String] = ["date,value"]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"

        let sorted = readings.sorted(by: { $0.date < $1.date })
        for r in sorted {
            let dateStr = df.string(from: r.date)
            let valueStr = String(format: "%.3f", r.value)
            lines.append("\(dateStr),\(valueStr)")
        }
        return lines.joined(separator: "\n") + "\n"
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText, .plainText] }

    var text: String

    init(text: String) { self.text = text }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let str = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) {
            self.text = str
        } else {
            self.text = ""
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return .init(regularFileWithContents: data)
    }
}

