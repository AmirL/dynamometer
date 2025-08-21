/** Requirements:
    - Allow user to choose between Light, Dark, and System appearance modes
    - Update settings immediately when selection changes
    - Display current selection clearly
*/

import SwiftUI
import SwiftData

struct AppearanceSettings: View {
    let settings: AppSettings
    let modelContext: ModelContext
    
    var body: some View {
        Section("Appearance") {
            Picker("Color Scheme", selection: appearanceBinding) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var appearanceBinding: Binding<AppearanceMode> {
        Binding(
            get: { settings.appearance },
            set: { newValue in
                settings.appearance = newValue
                try? modelContext.save()
            }
        )
    }
}