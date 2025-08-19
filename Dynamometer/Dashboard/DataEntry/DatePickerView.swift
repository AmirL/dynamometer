/** Requirements:
    - Date switcher showing "Now" by default
    - Toggle between "Now" mode and custom date picker
    - "Now" mode shows current date/time when saving
*/

import SwiftUI

struct DateSwitcherView: View {
    @Binding var date: Date
    @Binding var useCurrentTime: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Date")
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: { useCurrentTime.toggle() }) {
                    Text(useCurrentTime ? "Custom Date" : "Use Now")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(Theme.tint)
            }
            
            if useCurrentTime {
                HStack {
                    Text("Now")
                        .foregroundStyle(.primary)
                    Spacer()
                }
            } else {
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
            }
        }
    }
}