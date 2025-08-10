import Foundation
import SwiftData

@Model
final class AppSettings {
  var baselineMin: Double
  var baselineMax: Double
  var chartPeriod: String
  var chartScale: String
  var smaWindow: Int

  init(
    baselineMin: Double = 35,
    baselineMax: Double = 55,
    chartPeriod: String = "3M",
    chartScale: String = "D",
    smaWindow: Int = 7
  ) {
    self.baselineMin = baselineMin
    self.baselineMax = Swift.max(baselineMax, baselineMin)
    self.chartPeriod = chartPeriod
    self.chartScale = chartScale
    self.smaWindow = smaWindow
  }
}

