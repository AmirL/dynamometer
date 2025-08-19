/** Requirements:
    - Display reading value and date
    - Show classification badge with color coding
    - Format value with 1 decimal place and "kg" unit
*/

import SwiftUI

struct ReadingRow: View {
    let reading: Reading
    let settings: AppSettings
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(reading.value, specifier: "%.1f") kg")
                    .font(.headline)
                    .monospacedDigit()
                Text(reading.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            let tag = listTag(for: reading.value, with: settings)
            Pill(label: tag.label, color: tag.color)
        }
    }
}