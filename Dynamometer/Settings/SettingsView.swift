/** Requirements:
    - Main settings screen with form layout
    - Baseline configuration section
    - Chart preferences section  
    - Data import/export section
    - Last reading display
*/

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query(sort: \Reading.date, order: .reverse) private var readings: [Reading]
    @State private var showImporter = false
    @State private var showExporter = false
    @State private var importResultMessage: String?
    @State private var exportResultMessage: String?
    @State private var baselineMinText: String = ""
    @State private var baselineMaxText: String = ""
    @FocusState private var focusedField: BaselineField?

    var body: some View {
        NavigationStack {
            Form {
                if settingsBinding != nil {
                    BaselineEditor(
                        minText: $baselineMinText,
                        maxText: $baselineMaxText,
                        focusedField: $focusedField,
                        onUpdate: updateSettingFromTexts
                    )
                    
                    AutoCalculationButton(
                        recentReadings: recentReadings,
                        onRecalculate: recalc
                    )
                    
                    if let set = settings.first {
                        SMAConfiguration(settings: set, modelContext: modelContext)
                    }
                    
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
                    if let last = readings.first {
                        Section("Last Reading") {
                            Text("\(last.value, specifier: "%.1f") kg on \(last.date.formatted(date: .abbreviated, time: .omitted))")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    ContentUnavailableView("No Settings", systemImage: "gearshape", description: Text("Settings will be created automatically."))
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Settings")
            .onAppear { ensureSettings(); syncTextFromSettings() }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
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
    }

    private var settingsBinding: Binding<AppSettings>? {
        guard let first = settings.first else { return nil }
        return Binding(
            get: { first },
            set: { _ in try? modelContext.save() }
        )
    }

    private var recentReadings: [Reading] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -14, to: .now) ?? .distantPast
        return readings.filter { $0.date >= cutoff }
    }

    private func recalc() {
        guard let s = settings.first else { return }
        if let baseline = AutoCalculation.calculateBaseline(from: recentReadings) {
            s.baselineMin = baseline.min
            s.baselineMax = baseline.max
            try? modelContext.save()
            syncTextFromSettings()
        }
    }

    private func ensureSettings() {
        DefaultSettings.ensureExists(in: modelContext)
    }

    private func syncTextFromSettings() {
        guard let s = settings.first else { return }
        baselineMinText = NumberFormatting.formatValue(s.baselineMin)
        baselineMaxText = NumberFormatting.formatValue(s.baselineMax)
    }

    private func updateSettingFromTexts() {
        guard let s = settings.first else { return }
        let result = ValidationLogic.validateAndUpdate(
            settings: s,
            minText: baselineMinText,
            maxText: baselineMaxText
        )
        
        if result.shouldUpdateMaxText, let updatedMax = result.updatedMax {
            baselineMaxText = NumberFormatting.formatValue(updatedMax)
        }
        
        try? modelContext.save()
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
