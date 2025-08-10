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
    // Use the same shared colors as guidance labels
    switch self {
    case .below: return Theme.guidanceBelow
    case .within: return Theme.guidanceWithin
    case .above: return Theme.guidanceAbove
    }
  }

  var guidanceColor: Color {
    // Centralized color mapping
    switch self {
    case .below: return Theme.guidanceBelow
    case .within: return Theme.guidanceWithin
    case .above: return Theme.guidanceAbove
    }
  }

  // Trend-specific short labels for the pill.
  var trendGuidanceLabel: String {
    switch self {
    case .below: return "Take deload"
    case .within: return "Train Normally"
    case .above: return "Fully recovered"
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
  // Keep list labels, but use the same colors as guidance
  return (cat.listLabel, cat.guidanceColor)
}

func trainingGuidance(for value: Double, with settings: AppSettings) -> (label: String, color: Color) {
  let cat = classify(value, with: settings)
  return (cat.guidanceLabel, cat.guidanceColor)
}

func trendGuidance(for value: Double, with settings: AppSettings) -> (label: String, color: Color) {
  let cat = classify(value, with: settings)
  return (cat.trendGuidanceLabel, cat.guidanceColor)
}
