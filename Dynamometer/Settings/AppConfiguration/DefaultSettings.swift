/** Requirements:
    - Create AppSettings with reasonable baseline values
    - Auto-initialize when no settings exist
    - Provide sensible defaults for new users
*/

import SwiftData

struct DefaultSettings {
    static func create() -> AppSettings {
        AppSettings(
            baselineMin: AutoCalculation.defaultMin,
            baselineMax: AutoCalculation.defaultMax,
            smaWindow: 7            // Weekly moving average
        )
    }
    
    static func ensureExists(in context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<AppSettings>()
            let settings = try context.fetch(descriptor)
            
            if settings.isEmpty {
                let newSettings = create()
                context.insert(newSettings)
                try context.save()
            }
        } catch {
            // If fetch fails, create new settings anyway
            let newSettings = create()
            context.insert(newSettings)
            try? context.save()
        }
    }
}