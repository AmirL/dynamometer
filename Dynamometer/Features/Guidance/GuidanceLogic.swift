import SwiftUI
import SwiftData

enum GuidanceCategory {
  case below
  case within
  case above

  var listLabel: String {
    switch self {
    case .below: return "Below"
    case .within: return "Baseline"
    case .above: return "Above"
    }
  }

  var guidanceLabel: String {
    switch self {
    case .below: return "Take Rest"
    case .within: return "Train Normally"
    case .above: return "Go Hard"
    }
  }

  var listColor: Color {
    switch self {
    case .below: return .red
    case .within: return .gray
    case .above: return .green
    }
  }

  var guidanceColor: Color {
    switch self {
    case .below: return .orange
    case .within: return .blue
    case .above: return .green
    }
  }
}

// Core classification using the baseline corridor.
func classify(_ value: Double, with settings: AppSettings) -> GuidanceCategory {
  if value < settings.baselineMin { return .below }
  if value > settings.baselineMax { return .above }
  return .within
}

// Mapping helpers to keep labels/colors in one place.
func listTag(for value: Double, with settings: AppSettings) -> (label: String, color: Color) {
  let cat = classify(value, with: settings)
  return (cat.listLabel, cat.listColor)
}

func trainingGuidance(for value: Double, with settings: AppSettings) -> (label: String, color: Color) {
  let cat = classify(value, with: settings)
  return (cat.guidanceLabel, cat.guidanceColor)
}
