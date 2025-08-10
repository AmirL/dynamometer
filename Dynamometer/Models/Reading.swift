import Foundation
import SwiftData

@Model
final class Reading {
  var date: Date
  var value: Double

  init(date: Date = .now, value: Double) {
    self.date = date
    self.value = value
  }
}

