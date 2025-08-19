/** Requirements:
    - Show recent 10 readings in a section
    - Support swipe-to-delete functionality
    - Handle empty state gracefully
*/

import SwiftUI
import SwiftData

struct ReadingsList: View {
    let readings: [Reading]
    let settings: AppSettings
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        if !readings.isEmpty {
            Section(header: Text("Recent")) {
                ForEach(readings.prefix(10)) { reading in
                    ReadingRow(reading: reading, settings: settings)
                }
                .onDelete(perform: onDelete)
            }
        }
    }
}