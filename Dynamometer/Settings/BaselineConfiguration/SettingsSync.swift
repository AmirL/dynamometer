/** Requirements:
    - Synchronize text fields with AppSettings model
    - Handle baseline validation and constraint enforcement
    - Update text fields when validation adjusts values
    - Save changes to model context
*/

import Foundation
import SwiftData

struct SettingsSync {
    static func syncTextFromSettings(_ settings: AppSettings?) -> (minText: String, maxText: String) {
        guard let settings = settings else { return ("", "") }
        return (
            minText: NumberFormatting.formatValue(settings.baselineMin),
            maxText: NumberFormatting.formatValue(settings.baselineMax)
        )
    }
    
    static func updateSettingsFromText(
        settings: AppSettings,
        minText: String,
        maxText: String,
        modelContext: ModelContext
    ) -> String? {
        let result = settings.updateBaseline(minText: minText, maxText: maxText)
        
        var updatedMaxText: String? = nil
        if result.shouldUpdateMaxText, let updatedMax = result.updatedMax {
            updatedMaxText = NumberFormatting.formatValue(updatedMax)
        }
        
        try? modelContext.save()
        return updatedMaxText
    }
}