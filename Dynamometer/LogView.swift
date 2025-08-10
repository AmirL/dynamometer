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
                Section(header: Text("New Reading")) {
                    TextField("Grip strength (kg)", text: $valueText)
                        .keyboardType(.decimalPad)
                        .focused($valueFieldFocused)
                        .submitLabel(.done)
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                    Button(action: saveReading) {
                        Label("Save Reading", systemImage: "tray.and.arrow.down")
                    }.disabled(parsedValue == nil)
                }

                if !readings.isEmpty, let set = settings.first {
                    Section(header: Text("Recent")) {
                        ForEach(readings.prefix(10)) { r in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(r.value, specifier: "%.1f") kg")
                                        .font(.headline)
                                    Text(r.date, style: .date).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                let category = classify(r.value, with: set)
                                Text(category.label)
                                    .font(.caption).bold()
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(category.color.opacity(0.15))
                                    .foregroundStyle(category.color)
                                    .clipShape(Capsule())
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { valueFieldFocused = false }
                }
            }
            .navigationTitle("Dynamometer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
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
}
