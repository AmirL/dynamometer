/** Requirements:
    - Calculate baseline from recent 14 days of readings
    - Use median value ± 5% for corridor
    - Button to trigger recalculation
    - Disable when no recent readings available
*/

import SwiftUI
import SwiftData

struct AutoCalculation {
    // Default baseline values for new users
    static let defaultMin: Double = 35.0      // Reasonable adult baseline
    static let defaultMax: Double = 45.0      // 35-45kg typical range
    static func calculateBaseline(from readings: [Reading]) -> (min: Double, max: Double)? {
        guard !readings.isEmpty else { return nil }
        
        let values = readings.map(\.value).sorted()
        let median: Double = {
            let n = values.count
            if n % 2 == 1 {
                return values[n/2]
            } else {
                return (values[n/2 - 1] + values[n/2]) / 2
            }
        }()
        
        // Corridor = median ± 5%
        let min = max(0, median * 0.95)
        let max = median * 1.05
        
        return (min: min, max: max)
    }
}

struct AutoCalculationButton: View {
    let recentReadings: [Reading]
    let onRecalculate: () -> Void
    
    var body: some View {
        Button("Recalculate from last 14 days", action: onRecalculate)
            .disabled(recentReadings.isEmpty)
    }
}