/** Requirements:
    - Stepper control for SMA window (1-30 days)
    - Show current value with "days" label
    - Auto-save changes to model context
    - Clamp values to valid range
*/

import SwiftUI
import SwiftData

struct SMAConfiguration: View {
    let settings: AppSettings
    let modelContext: ModelContext
    
    var body: some View {
        Section(header: Text("Chart Settings")) {
            HStack {
                Text("SMA Window")
                Spacer()
                Stepper("\(settings.smaWindow) days", value: Binding(
                    get: { settings.smaWindow },
                    set: { newValue in
                        settings.smaWindow = max(1, min(30, newValue))
                        try? modelContext.save()
                    }
                ), in: 1...30)
            }
        }
    }
}