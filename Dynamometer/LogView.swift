import SwiftUI
import SwiftData

struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reading.date, order: .reverse) private var readings: [Reading]
    @Query private var settings: [AppSettings]

    @State private var valueText: String = ""
    @State private var date: Date = .now
    @FocusState private var valueFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                AddLogSection()
                if !readings.isEmpty, let set = settings.first {
                    recentLogsSection(settings: set)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Dynamometer")
            .toolbar { keyboardToolbar }
            .toolbar { trailingToolbar }
        }
    }

    private var parsedValue: Double? {
        Double(valueText.replacingOccurrences(of: ",", with: "."))
    }

    private func saveReading() {
        guard let v = parsedValue else { return }
        let reading = Reading(date: date, value: v)
        modelContext.insert(reading)
        try? modelContext.save()
        valueText = ""
        valueFieldFocused = false
        date = .now
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(readings[i]) }
        try? modelContext.save()
    }

    private func classify(_ value: Double, with settings: AppSettings) -> (label: String, color: Color) {
        if value < settings.baselineMin { return ("Below", .red) }
        if value > settings.baselineMax { return ("Above", .green) }
        return ("Baseline", .gray)
    }
    
    // MARK: - Sections

    @ViewBuilder
    private func AddLogSection() -> some View {
        Section(header: Text("New Reading")) {
            TextField("Grip strength (kg)", text: $valueText)
                .keyboardType(.decimalPad)
                .focused($valueFieldFocused)
                .submitLabel(.done)
            DatePicker("Date", selection: $date, displayedComponents: [.date])
            Button(action: saveReading) {
                Label("Save Reading", systemImage: "tray.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.tint)
            .disabled(parsedValue == nil)
        }
    }
    
    @ViewBuilder
    private func recentLogsSection(settings: AppSettings) -> some View {
        Section(header: Text("Recent")) {
            ForEach(readings.prefix(10)) { r in
                LogRow(reading: r, settings: settings)
            }
            .onDelete(perform: delete)
        }
    }
    
    // MARK: - Toolbars
    
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { valueFieldFocused = false }
        }
    }
    
    private var trailingToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            EditButton()
        }
    }
}

// MARK: - Subviews

private struct LogRow: View {
    let reading: Reading
    let settings: AppSettings

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(reading.value, specifier: "%.1f") kg")
                    .font(.headline)
                    .monospacedDigit()
                Text(reading.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            let category = classify(reading.value, with: settings)
            Text(category.label)
                .font(.caption).bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(category.color.opacity(0.15))
                .foregroundStyle(category.color)
                .clipShape(Capsule())
        }
    }

    private func classify(_ value: Double, with settings: AppSettings) -> (label: String, color: Color) {
        if value < settings.baselineMin { return ("Below", .red) }
        if value > settings.baselineMax { return ("Above", .green) }
        return ("Baseline", .gray)
    }
}
