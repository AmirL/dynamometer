/** Requirements:
    - Display most recent reading with date and value
    - Show in separate section within settings form
    - Handle case when no readings exist
*/

import SwiftUI

struct LastReadingDisplay: View {
    let lastReading: Reading?
    
    var body: some View {
        if let reading = lastReading {
            Section("Last Reading") {
                Text("\(reading.value, specifier: "%.1f") kg on \(reading.date.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.secondary)
            }
        }
    }
}