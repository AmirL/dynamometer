/** Requirements:
    - Show today's reading classification with color coding
    - Display performance feedback messages
    - Help button for guidance explanations
*/

import SwiftUI
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
      GuidanceInfoView(settings: settings, mode: .training)
    }
  }
}

// Help popup describing how guidance thresholds work, with numbers.
enum GuidanceInfoMode { case training, trend }

struct GuidanceInfoView: View {
  let settings: AppSettings
  var mode: GuidanceInfoMode = .training

  var body: some View {
    NavigationStack {
      List {
        Section("How Guidance Is Determined") {
          ruleRow(title: "< \(fmt(settings.baselineMin))", category: .below)
          ruleRow(title: "\(fmt(settings.baselineMin)) – \(fmt(settings.baselineMax))", category: .within)
          ruleRow(title: "> \(fmt(settings.baselineMax))", category: .above)
        }
      }
      .navigationTitle(mode == .training ? "Guidance Help" : "Trend Guidance Help")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func ruleRow(title: String, category: GuidanceCategory) -> some View {
    HStack {
      Text(title)
      Spacer()
      let label = (mode == .training) ? category.guidanceLabel : category.trendGuidanceLabel
      Pill(label: label, color: category.guidanceColor)
    }
  }

  private func fmt(_ value: Double) -> String { String(format: "%.1f", value) }
}

// Trend summary row using the latest SMA value.
struct TrendGuidanceSection: View {
  let trendValue: Double
  let settings: AppSettings
  @State private var showTrendHelp = false

  var body: some View {
    Section {
      let guide = trendGuidance(for: trendValue, with: settings)
      HStack {
        Text("Trend Guidance")
        Button(action: { showTrendHelp = true }) {
          Image(systemName: "questionmark.circle").imageScale(.medium)
        }
        .buttonStyle(.plain)
        Spacer()
        Pill(label: guide.label, color: guide.color)
      }
    }
    .sheet(isPresented: $showTrendHelp) {
      GuidanceInfoView(settings: settings, mode: .trend)
    }
  }
}
