/** Requirements:
    - Handle SwiftData model context operations
    - Safe save operations with error handling
    - Provide bindings for SwiftUI forms
*/

import SwiftData
import SwiftUI

struct PersistenceLayer {
    static func safeBinding<T>(
        for keyPath: ReferenceWritableKeyPath<AppSettings, T>,
        settings: AppSettings,
        context: ModelContext
    ) -> Binding<T> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in
                settings[keyPath: keyPath] = newValue
                try? context.save()
            }
        )
    }
    
    static func safeSave(context: ModelContext) {
        do {
            try context.save()
        } catch {
            // Log error in production app
            print("Failed to save context: \(error)")
        }
    }
    
    static func settingsBinding(
        from settings: [AppSettings],
        context: ModelContext
    ) -> Binding<AppSettings>? {
        guard let first = settings.first else { return nil }
        
        return Binding(
            get: { first },
            set: { _ in safeSave(context: context) }
        )
    }
}