/** Requirements:
    - Parse decimals with comma or dot
    - Only allow 0-200kg grip strength  
    - Dates must be within past year, no future dates
*/

import Foundation

struct InputValidation {
    static func isValidGripStrength(_ value: Double?) -> Bool {
        guard let value = value else { return false }
        return value > 0 && value <= 200
    }

    static func isValidDate(_ date: Date) -> Bool {
        let now = Date()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? Date.distantPast
        return date >= oneYearAgo && date <= now
    }
}