//
//  Item.swift
//  Dynamometer
//
//  Created by Amir on 09.08.2025.
//

import Foundation
import SwiftData

struct ChartDataPoint {
    let date: Date
    let value: Double
    let smaValue: Double?
}

extension Array where Element == Reading {
    func filteredByPeriod(_ period: String, scale: String, smaWindow: Int = 7) -> [ChartDataPoint] {
        let now = Date()
        let calendar = Calendar.current
        
        let cutoffDate: Date = {
            switch period {
            case "1W": return calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? .distantPast
            case "1M": return calendar.date(byAdding: .month, value: -1, to: now) ?? .distantPast
            case "3M": return calendar.date(byAdding: .month, value: -3, to: now) ?? .distantPast
            case "6M": return calendar.date(byAdding: .month, value: -6, to: now) ?? .distantPast
            case "1Y": return calendar.date(byAdding: .year, value: -1, to: now) ?? .distantPast
            case "All": return .distantPast
            default: return calendar.date(byAdding: .month, value: -3, to: now) ?? .distantPast
            }
        }()
        
        let filtered = self.filter { $0.date >= cutoffDate }.sorted { $0.date < $1.date }
        
        if scale == "W" {
            return aggregateWeekly(filtered, smaWindow: Swift.max(3, smaWindow / 2))
        } else {
            return aggregateDaily(filtered, smaWindow: smaWindow)
        }
    }
    
    private func aggregateDaily(_ readings: [Reading], smaWindow: Int) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var dailyGroups: [String: [Reading]] = [:]
        
        for reading in readings {
            let dayKey = calendar.dateInterval(of: .day, for: reading.date)?.start.formatted(.iso8601) ?? ""
            dailyGroups[dayKey, default: []].append(reading)
        }
        
        let dailyAverages = dailyGroups.compactMap { (key, readings) -> (Date, Double)? in
            guard let date = ISO8601DateFormatter().date(from: key) else { return nil }
            let avgValue = readings.map(\.value).reduce(0, +) / Double(readings.count)
            return (date, avgValue)
        }.sorted { $0.0 < $1.0 }
        
        return calculateSMA(dailyAverages, window: smaWindow)
    }
    
    private func aggregateWeekly(_ readings: [Reading], smaWindow: Int) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var weeklyGroups: [String: [Reading]] = [:]
        
        for reading in readings {
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: reading.date)
            let weekKey = weekInterval?.start.formatted(.iso8601) ?? ""
            weeklyGroups[weekKey, default: []].append(reading)
        }
        
        let weeklyAverages = weeklyGroups.compactMap { (key, readings) -> (Date, Double)? in
            guard let date = ISO8601DateFormatter().date(from: key) else { return nil }
            let avgValue = readings.map(\.value).reduce(0, +) / Double(readings.count)
            return (date, avgValue)
        }.sorted { $0.0 < $1.0 }
        
        return calculateSMA(weeklyAverages, window: smaWindow)
    }
    
    private func calculateSMA(_ dataPoints: [(Date, Double)], window: Int) -> [ChartDataPoint] {
        var result: [ChartDataPoint] = []
        
        for i in 0..<dataPoints.count {
            let (date, value) = dataPoints[i]
            
            let smaValue: Double? = {
                if i >= window - 1 {
                    let smaSum = (i - window + 1...i).reduce(0.0) { sum, index in
                        sum + dataPoints[index].1
                    }
                    return smaSum / Double(window)
                }
                return nil
            }()
            
            result.append(ChartDataPoint(date: date, value: value, smaValue: smaValue))
        }
        
        return result
    }
}

@Model
final class Reading {
    var date: Date
    var value: Double

    init(date: Date = .now, value: Double) {
        self.date = date
        self.value = value
    }
}

@Model
final class AppSettings {
    var baselineMin: Double
    var baselineMax: Double
    var chartPeriod: String
    var chartScale: String
    var smaWindow: Int

    init(baselineMin: Double = 35, baselineMax: Double = 55, chartPeriod: String = "3M", chartScale: String = "D", smaWindow: Int = 7) {
        self.baselineMin = baselineMin
        self.baselineMax = Swift.max(baselineMax, baselineMin)
        self.chartPeriod = chartPeriod
        self.chartScale = chartScale
        self.smaWindow = smaWindow
    }
}
