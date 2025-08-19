/** Requirements:
    - Parse decimal text with comma/dot support
    - Ensure min ≤ max constraint
    - Auto-adjust max if min becomes larger
    - Validate reasonable grip strength ranges
*/

import Foundation

struct ValidationLogic {
    static func validateAndUpdate(
        settings: AppSettings,
        minText: String,
        maxText: String
    ) -> (updatedMax: Double?, shouldUpdateMaxText: Bool) {

        let minVal = NumberFormatting.parseDecimal(minText)
        let maxVal = NumberFormatting.parseDecimal(maxText)

        var updatedMax: Double? = nil
        var shouldUpdateMaxText = false

        // Update min value
        if let minVal = minVal {
            settings.baselineMin = minVal

            // Ensure max >= min
            if minVal > settings.baselineMax {
                settings.baselineMax = minVal
                updatedMax = minVal
                shouldUpdateMaxText = true
            }
        }

        // Update max value (if it's valid and >= min)
        if let maxVal = maxVal {
            let newMax = max(maxVal, settings.baselineMin)
            settings.baselineMax = newMax

            if newMax != maxVal {
                updatedMax = newMax
                shouldUpdateMaxText = true
            }
        }

        return (updatedMax: updatedMax, shouldUpdateMaxText: shouldUpdateMaxText)
    }


}