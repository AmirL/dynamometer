/** Requirements:
    - Parse decimal text with comma or dot separators
    - Format numbers consistently across the app
    - Handle European and US decimal formats
*/

import Foundation

struct NumberFormatting {
    /// Parse decimal text accepting both comma and dot as decimal separator
    static func parseDecimal(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
    
    /// Format double value to 1 decimal place for display
    static func formatValue(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
    
    /// Format double value to specified decimal places
    static func formatValue(_ value: Double, decimalPlaces: Int) -> String {
        String(format: "%.\(decimalPlaces)f", value)
    }
}