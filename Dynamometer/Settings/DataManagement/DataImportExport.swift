/** Requirements:
    - Data import/export section with file picker buttons
    - CSV import with deduplication against existing readings
    - Export readings to CSV with success/error handling
    - Alert display for import/export results
*/

import SwiftUI
import SwiftData

struct DataImportExport: View {
    @Environment(\.modelContext) private var modelContext
    let readings: [Reading]
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var importResultMessage: String?
    @State private var exportResultMessage: String?
    
    var body: some View {
        Section(header: Text("Data")) {
            FileHandling.importButton(
                isPresented: $showImporter,
                onImport: importCSV,
                onError: { error in
                    importResultMessage = ErrorManagement.formatImportError(error)
                }
            )
            
            FileHandling.exportButton(
                isPresented: $showExporter,
                csvContent: CSVExport.makeCSV(from: readings),
                onComplete: { result in
                    switch result {
                    case .success:
                        exportResultMessage = ErrorManagement.exportSuccess
                    case .failure(let error):
                        exportResultMessage = ErrorManagement.formatExportError(error)
                    }
                }
            )
        }
        .alert(
            isPresented: Binding(get: { importResultMessage != nil }, set: { if !$0 { importResultMessage = nil } })
        ) {
            ErrorManagement.importAlert(
                message: $importResultMessage,
                isPresented: Binding(get: { importResultMessage != nil }, set: { if !$0 { importResultMessage = nil } })
            )
        }
        .alert(
            isPresented: Binding(get: { exportResultMessage != nil }, set: { if !$0 { exportResultMessage = nil } })
        ) {
            ErrorManagement.exportAlert(
                message: $exportResultMessage,
                isPresented: Binding(get: { exportResultMessage != nil }, set: { if !$0 { exportResultMessage = nil } })
            )
        }
    }
    
    private func importCSV(from url: URL) {
        do {
            let text = try FileHandling.readFileContent(from: url)
            let pairs = CSVImport.parse(text: text)
            
            if pairs.isEmpty {
                importResultMessage = ErrorManagement.noReadingsFound
                return
            }

            // Deduplicate by exact (date,value) against current readings
            let existing: Set<String> = Set(readings.map { keyFor($0.date, $0.value) })
            var imported = 0
            for (d, v) in pairs {
                let key = keyFor(d, v)
                if existing.contains(key) { continue }
                let r = Reading(date: d, value: v)
                modelContext.insert(r)
                imported += 1
            }
            try? modelContext.save()
            importResultMessage = ErrorManagement.formatImportSuccess(count: imported)
        } catch {
            importResultMessage = ErrorManagement.formatImportError(error)
        }
    }

    private func keyFor(_ date: Date, _ value: Double) -> String {
        let t = String(format: "%.3f", date.timeIntervalSince1970)
        let v = String(format: "%.5f", value)
        return "\(t)|\(v)"
    }
}