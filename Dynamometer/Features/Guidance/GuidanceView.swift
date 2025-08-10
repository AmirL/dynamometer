import SwiftUI

// Compact summary row shown under the chart.
struct GuidanceSummarySection: View {
  let value: Double
  let settings: AppSettings
  @State private var showGuidanceHelp = false

  var body: some View {
    Section {
      let guide = trainingGuidance(for: value, with: settings)
      HStack {
        Text("Today's Guidance")
        Button(action: { showGuidanceHelp = true }) {
          Image(systemName: "questionmark.circle").imageScale(.medium)
        }
        .buttonStyle(.plain)
        Spacer()
        Pill(label: guide.label, color: guide.color)
      }
    }
    .sheet(isPresented: $showGuidanceHelp) {
      GuidanceInfoView(settings: settings)
    }
  }
}

// Help popup describing how guidance thresholds work, with numbers.
struct GuidanceInfoView: View {
  let settings: AppSettings

  var body: some View {
    NavigationStack {
      List {
        Section("How Guidance Is Determined") {
          ruleRow(title: "< \(fmt(settings.baselineMin))", category: .below)
          ruleRow(title: "\(fmt(settings.baselineMin)) – \(fmt(settings.baselineMax))", category: .within)
          ruleRow(title: "> \(fmt(settings.baselineMax))", category: .above)
        }
      }
      .navigationTitle("Guidance Help")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func ruleRow(title: String, category: GuidanceCategory) -> some View {
    HStack {
      Text(title)
      Spacer()
      Pill(label: category.guidanceLabel, color: category.guidanceColor)
    }
  }

  private func fmt(_ value: Double) -> String { String(format: "%.1f", value) }
}
