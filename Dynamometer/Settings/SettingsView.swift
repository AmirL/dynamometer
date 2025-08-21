/** Requirements:
    - Main settings screen with form layout
    - Baseline configuration section
    - Chart preferences section  
    - Data import/export section
    - Last reading display
*/

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query(sort: \Reading.date, order: .reverse) private var readings: [Reading]
    @State private var baselineMinText: String = ""
    @State private var baselineMaxText: String = ""
    @FocusState private var focusedField: BaselineField?

    var body: some View {
        NavigationStack {
            Form {
                if settingsBinding != nil {
                    if let set = settings.first {
                        AppearanceSettings(settings: set, modelContext: modelContext)
                    }
                    
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
                    
                    DataImportExport(readings: readings)
                    
                    LastReadingDisplay(lastReading: readings.first)
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
        let (minText, maxText) = SettingsSync.syncTextFromSettings(settings.first)
        baselineMinText = minText
        baselineMaxText = maxText
    }

    private func updateSettingFromTexts() {
        guard let s = settings.first else { return }
        let updatedMaxText = SettingsSync.updateSettingsFromText(
            settings: s,
            minText: baselineMinText,
            maxText: baselineMaxText,
            modelContext: modelContext
        )
        
        if let updatedMax = updatedMaxText {
            baselineMaxText = updatedMax
        }
    }
}
