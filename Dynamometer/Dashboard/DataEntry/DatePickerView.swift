/** Requirements:
    - Simple date picker labeled "Date"
    - Date only, no time selection
*/

import SwiftUI

struct DatePickerView: View {
    @Binding var date: Date
    
    var body: some View {
        DatePicker("Date", selection: $date, displayedComponents: [.date])
    }
}