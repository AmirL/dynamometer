/** Requirements:
    - User-friendly error messages for import/export failures
    - Alert dialogs with proper dismissal actions
    - Success feedback for completed operations
*/

import SwiftUI

struct ErrorManagement {
    static func importAlert(
        message: Binding<String?>,
        isPresented: Binding<Bool>
    ) -> Alert {
        Alert(
            title: Text("Import"),
            message: Text(message.wrappedValue ?? ""),
            dismissButton: .default(Text("OK")) {
                message.wrappedValue = nil
            }
        )
    }
    
    static func exportAlert(
        message: Binding<String?>,
        isPresented: Binding<Bool>
    ) -> Alert {
        Alert(
            title: Text("Export"),
            message: Text(message.wrappedValue ?? ""),
            dismissButton: .default(Text("OK")) {
                message.wrappedValue = nil
            }
        )
    }
    
    static func formatImportError(_ error: Error) -> String {
        "Import failed: \(error.localizedDescription)"
    }
    
    static func formatExportError(_ error: Error) -> String {
        "Export failed: \(error.localizedDescription)"
    }
    
    static func formatImportSuccess(count: Int) -> String {
        "Imported \(count) readings"
    }
    
    static let exportSuccess = "Exported CSV"
    static let noReadingsFound = "No readings found in file"
}