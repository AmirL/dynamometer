/** Requirements:
    - Form section for adding new readings
    - Value input field and date picker
    - Save button (disabled until valid input)
*/

import SwiftUI
import SwiftData

#Preview {
    @Previewable @State var valueText = ""
    @Previewable @FocusState var valueFieldFocused: Bool
    
    DataEntrySection(
        valueText: $valueText,
        valueFieldFocused: $valueFieldFocused,
        onSave: { print("Save tapped") }
    )
}

struct DataEntrySection: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var valueText: String
    @FocusState.Binding var valueFieldFocused: Bool

    let onSave: () -> Void

    private var isValidInput: Bool {
        guard let value = NumberFormatting.parseDecimal(valueText) else { return false }
        return Reading.isValidGripStrength(value)
    }

    var body: some View {
        Section(header: Text("Add value")) {
            HStack {
                ValueInputView(valueText: $valueText, isFocused: $valueFieldFocused)
                Button(action: onSave) {
                    Label("Add", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .tint(Theme.tint)
                .disabled(!isValidInput)
            }
        }
    }
}