/** Requirements:
    - Provide delete actions for individual readings
    - Support bulk operations if needed
    - Handle data persistence after deletions
*/

import SwiftUI
import SwiftData

struct ListActions {
    static func deleteReadings(at offsets: IndexSet, from readings: [Reading], context: ModelContext) {
        for index in offsets {
            context.delete(readings[index])
        }
        try? context.save()
    }
    
    // Future: Add bulk operations like "Clear all" or "Export selected"
}