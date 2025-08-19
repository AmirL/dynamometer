/** Requirements:
    - Form section for adding new readings
    - Value input field and date picker
    - Save button (disabled until valid input)
*/

import SwiftUI
import SwiftData

struct DataEntrySection: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var valueText: String
    @Binding var date: Date
    @FocusState.Binding var valueFieldFocused: Bool

    let onSave: () -> Void

    private var isValidInput: Bool {
        guard let value = NumberFormatting.parseDecimal(valueText) else { return false }
        return Reading.isValidGripStrength(value) && Reading.isValidDate(date)
    }

    var body: some View {
        Section(header: Text("Add value")) {
            ValueInputView(valueText: $valueText, isFocused: $valueFieldFocused)
            DatePickerView(date: $date)
            Button(action: onSave) {
                Label("Add", systemImage: "tray.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.tint)
            .disabled(!isValidInput)
        }
    }
}