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
  
  // MARK: - Validation
  
  static func isValidGripStrength(_ value: Double?) -> Bool {
    guard let value = value else { return false }
    return value > 0 && value <= 200
  }
  
  static func isValidDate(_ date: Date) -> Bool {
    let now = Date()
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? Date.distantPast
    return date >= oneYearAgo && date <= now
  }
  
  var isValid: Bool {
    return Self.isValidGripStrength(value) && Self.isValidDate(date)
  }
  
  static func create(date: Date = .now, value: Double) -> Reading? {
    guard isValidGripStrength(value) && isValidDate(date) else {
      return nil
    }
    return Reading(date: date, value: value)
  }
}

