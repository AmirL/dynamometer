import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @Query(sort: \Reading.date, order: .reverse) private var readings: [Reading]
    @State private var showImporter = false
    @State private var importResultMessage: String?
    @State private var baselineMinText: String = ""
    @State private var baselineMaxText: String = ""
    @FocusState private var focusedField: Field?

    private enum Field { case min, max }

    var body: some View {
        NavigationStack {
            Form {
                if settingsBinding != nil {
                    Section(header: Text("Baseline Corridor (kg)")) {
                        HStack {
                            Text("Min")
                            Spacer()
                            TextField("Min", text: $baselineMinText)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(maxWidth: 120)
                                .focused($focusedField, equals: .min)
                                .submitLabel(.done)
                                .onChange(of: baselineMinText) {
                                    updateSettingFromTexts()
                                }
                        }
                        HStack {
                            Text("Max")
                            Spacer()
                            TextField("Max", text: $baselineMaxText)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(maxWidth: 120)
                                .focused($focusedField, equals: .max)
                                .submitLabel(.done)
                                .onChange(of: baselineMaxText) {
                                    updateSettingFromTexts()
                                }
                        }
                        Button("Recalculate from last 14 days", action: recalc)
                            .disabled(recentReadings.isEmpty)
                    }
                    
                    if let set = settings.first {
                        Section(header: Text("Chart Settings")) {
                            HStack {
                                Text("SMA Window")
                                Spacer()
                                Stepper("\(set.smaWindow) days", value: Binding(
                                    get: { set.smaWindow },
                                    set: { set.smaWindow = max(1, min(30, $0)); try? modelContext.save() }
                                ), in: 1...30)
                            }
                        }
                    }
                    
                    Section(header: Text("Data")) {
                        Button {
                            showImporter = true
                        } label: {
                            Label("Import CSV", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.tint)
                        .fileImporter(isPresented: $showImporter, allowedContentTypes: [UTType.commaSeparatedText, .plainText]) { res in
                            switch res {
                            case .success(let url):
                                importCSV(from: url)
                            case .failure(let err):
                                importResultMessage = "Import failed: \(err.localizedDescription)"
                            }
                        }
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
            .alert("Import", isPresented: Binding(get: { importResultMessage != nil }, set: { if !$0 { importResultMessage = nil } })) {
                Button("OK", role: .cancel) { importResultMessage = nil }
            } message: {
                Text(importResultMessage ?? "")
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
        let values = recentReadings.map(\.value).sorted()
        guard !values.isEmpty else { return }
        let median: Double = {
            let n = values.count
            if n % 2 == 1 { return values[n/2] }
            return (values[n/2 - 1] + values[n/2]) / 2
        }()
        // Corridor = median ± 5%
        s.baselineMin = max(0, median * 0.95)
        s.baselineMax = median * 1.05
        try? modelContext.save()
        syncTextFromSettings()
    }

    private func ensureSettings() {
        if settings.isEmpty {
            modelContext.insert(AppSettings())
            try? modelContext.save()
        }
    }

    private func syncTextFromSettings() {
        guard let s = settings.first else { return }
        baselineMinText = String(format: "%.1f", s.baselineMin)
        baselineMaxText = String(format: "%.1f", s.baselineMax)
    }

    private func updateSettingFromTexts() {
        guard let s = settings.first else { return }
        let minVal = parseDouble(baselineMinText)
        let maxVal = parseDouble(baselineMaxText)
        var changed = false
        if let minVal {
            if s.baselineMin != minVal { s.baselineMin = minVal; changed = true }
            if minVal > s.baselineMax { s.baselineMax = minVal; changed = true; baselineMaxText = String(format: "%.1f", s.baselineMax) }
        }
        if let maxVal {
            let newMax = max(maxVal, minVal ?? s.baselineMin)
            if s.baselineMax != newMax { s.baselineMax = newMax; changed = true }
        }
        if changed { try? modelContext.save() }
    }

    private func parseDouble(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: "."))
    }

    private func importCSV(from url: URL) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
                importResultMessage = "Unsupported file encoding"
                return
            }
            let pairs = CSVImport.parse(text: text)
            if pairs.isEmpty {
                importResultMessage = "No readings found in file"
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
            importResultMessage = "Imported \(imported) readings"
        } catch {
            importResultMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    private func keyFor(_ date: Date, _ value: Double) -> String {
        let t = String(format: "%.3f", date.timeIntervalSince1970)
        let v = String(format: "%.5f", value)
        return "\(t)|\(v)"
    }
}
