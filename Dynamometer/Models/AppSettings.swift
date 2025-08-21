import Foundation
import SwiftData

enum AppearanceMode: String, CaseIterable, Codable {
  case light = "light"
  case dark = "dark"
  case system = "system"
  
  var displayName: String {
    switch self {
    case .light: return "Light"
    case .dark: return "Dark"
    case .system: return "System"
    }
  }
}

@Model
final class AppSettings {
  var baselineMin: Double
  var baselineMax: Double
  var chartPeriod: String
  var chartScale: String
  var smaWindow: Int
  var appearanceMode: String

  init(
    baselineMin: Double = 35,
    baselineMax: Double = 55,
    chartPeriod: String = "3M",
    chartScale: String = "D",
    smaWindow: Int = 7,
    appearanceMode: AppearanceMode = .system
  ) {
    self.baselineMin = baselineMin
    self.baselineMax = Swift.max(baselineMax, baselineMin)
    self.chartPeriod = chartPeriod
    self.chartScale = chartScale
    self.smaWindow = smaWindow
    self.appearanceMode = appearanceMode.rawValue
  }
  
  var appearance: AppearanceMode {
    get { AppearanceMode(rawValue: appearanceMode) ?? .system }
    set { appearanceMode = newValue.rawValue }
  }
  
  // MARK: - Baseline Validation
  
  static func isValidBaselineRange(min: Double, max: Double) -> Bool {
    return min >= 0 && max >= min && max <= 200
  }
  
  func updateBaseline(minText: String, maxText: String) -> (updatedMax: Double?, shouldUpdateMaxText: Bool) {
    let minVal = NumberFormatting.parseDecimal(minText)
    let maxVal = NumberFormatting.parseDecimal(maxText)
    
    var updatedMax: Double? = nil
    var shouldUpdateMaxText = false
    
    // Update min value
    if let minVal = minVal, minVal >= 0 && minVal <= 200 {
      baselineMin = minVal
      
      // Ensure max >= min
      if minVal > baselineMax {
        baselineMax = minVal
        updatedMax = minVal
        shouldUpdateMaxText = true
      }
    }
    
    // Update max value (if it's valid and >= min)
    if let maxVal = maxVal, maxVal <= 200 {
      let newMax = max(maxVal, baselineMin)
      baselineMax = newMax
      
      if newMax != maxVal {
        updatedMax = newMax
        shouldUpdateMaxText = true
      }
    }
    
    return (updatedMax: updatedMax, shouldUpdateMaxText: shouldUpdateMaxText)
  }
  
  var isValidBaseline: Bool {
    return Self.isValidBaselineRange(min: baselineMin, max: baselineMax)
  }
}

