/** Requirements:
    - Text field for grip strength with decimal keyboard
    - Show "Grip strength (kg)" placeholder
    - Handle focus state for keyboard control
*/

import SwiftUI

struct ValueInputView: View {
    @Binding var valueText: String
    @FocusState.Binding var isFocused: Bool
    
    var parsedValue: Double? {
        NumberFormatting.parseDecimal(valueText)
    }
    
    var body: some View {
        TextField("Grip strength (kg)", text: $valueText)
            .keyboardType(.decimalPad)
            .focused($isFocused)
            .submitLabel(.done)
    }
}