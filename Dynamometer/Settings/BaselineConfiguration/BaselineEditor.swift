/** Requirements:
    - Text fields for min/max baseline values
    - Decimal keyboard with proper validation
    - Real-time updates as user types
    - Focus management between fields
*/

import SwiftUI

struct BaselineEditor: View {
    @Binding var minText: String
    @Binding var maxText: String
    @FocusState.Binding var focusedField: BaselineField?
    let onUpdate: () -> Void
    
    var body: some View {
        Section(header: Text("Baseline Corridor (kg)")) {
            HStack {
                Text("Min")
                Spacer()
                TextField("Min", text: $minText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 120)
                    .focused($focusedField, equals: .min)
                    .submitLabel(.done)
                    .onChange(of: minText) { onUpdate() }
            }
            HStack {
                Text("Max")
                Spacer()
                TextField("Max", text: $maxText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .frame(maxWidth: 120)
                    .focused($focusedField, equals: .max)
                    .submitLabel(.done)
                    .onChange(of: maxText) { onUpdate() }
            }
        }
    }
}

enum BaselineField {
    case min, max
}