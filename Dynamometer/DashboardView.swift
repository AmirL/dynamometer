import SwiftUI
import SwiftData

struct DashboardView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var readings: [Reading] = []
  @State private var settings: [AppSettings] = []

  @State private var valueText: String = ""
  @State private var date: Date = .now
  @FocusState private var valueFieldFocused: Bool

  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  @State private var showGuidanceHelp: Bool = false

  var body: some View {
    NavigationStack {
      Form {
        Section {
          ChartView(chartHeight: chartHeight)
        }

        if let today = todayReading, let set = settings.first {
          GuidanceSummarySection(value: today.value, settings: set)
        }

        if let set = settings.first, let trend = latestTrendValue(for: set) {
          TrendGuidanceSection(trendValue: trend, settings: set)
        }

        DataEntrySection(
          valueText: $valueText,
          date: $date,
          valueFieldFocused: $valueFieldFocused,
          onSave: saveReading
        )

        if let set = settings.first {
          ReadingsList(readings: readings, settings: set, onDelete: delete)
        }
      }
      .formStyle(.grouped)
      .scrollContentBackground(.hidden)
      .background(Theme.backgroundGradient.ignoresSafeArea())
      .scrollDismissesKeyboard(.interactively)
      .navigationTitle("Dynamometer")
      .toolbar { keyboardToolbar }
      .toolbar { trailingToolbar }
      .onAppear { reload() }
    }
  }

  private var chartHeight: CGFloat {
    // Prefer a shorter chart in portrait on phones
    if hSize == .some(.compact) && vSize == .some(.regular) {
      return 260
    }
    return 320
  }


  private func saveReading() {
    guard let v = NumberFormatting.parseDecimal(valueText),
          let reading = Reading.create(date: date, value: v) else { return }
    modelContext.insert(reading)
    try? modelContext.save()
    valueText = ""
    valueFieldFocused = false
    date = .now
    reload()
  }

  private func delete(at offsets: IndexSet) {
    ListActions.deleteReadings(at: offsets, from: readings, context: modelContext)
    reload()
  }

  private func reload() {
    do {
      let readingDesc = FetchDescriptor<Reading>(
        sortBy: [SortDescriptor(\.date, order: .reverse)]
      )
      readings = try modelContext.fetch(readingDesc)
      let settingsDesc = FetchDescriptor<AppSettings>()
      settings = try modelContext.fetch(settingsDesc)
      if settings.isEmpty {
        modelContext.insert(AppSettings())
        try? modelContext.save()
        settings = (try? modelContext.fetch(settingsDesc)) ?? []
      }
    } catch {
      readings = []
      settings = []
    }
  }

  private var todayReading: Reading? {
    let cal = Calendar.current
    return readings.first(where: { cal.isDateInToday($0.date) })
  }

  private func latestTrendValue(for settings: AppSettings) -> Double? {
    // Use the full dataset to ensure we have enough points for SMA
    let data = readings.filteredByPeriod("All", scale: settings.chartScale, smaWindow: settings.smaWindow)
    return data.compactMap(\.smaValue).last
  }

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


 
