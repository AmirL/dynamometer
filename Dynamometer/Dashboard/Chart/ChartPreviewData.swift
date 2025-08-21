/** Requirements:
    - Generate realistic test data for chart previews
    - Create cyclic patterns with noise and trends
    - Support different data scenarios for testing
*/

import Foundation
import SwiftData

struct ChartPreviewData {
    
    static func generateCyclicReadings(
        months: Int = 4,
        baseValue: Double = 45.0,
        cycleAmplitude: Double = 15.0,
        cycleLength: Int = 21,
        noise: Double = 3.0,
        trend: Double = 0.1
    ) -> [Reading] {
        let calendar = Calendar.current
        let endDate = Date.now
        let startDate = calendar.date(byAdding: .month, value: -months, to: endDate)!
        
        var readings: [Reading] = []
        var currentDate = startDate
        var dayIndex = 0
        
        while currentDate <= endDate {
            let cyclePhase = (Double(dayIndex % cycleLength) / Double(cycleLength)) * 2 * Double.pi
            let cycleValue = sin(cyclePhase) * cycleAmplitude
            
            let trendValue = Double(dayIndex) * trend
            let noiseValue = Double.random(in: -noise...noise)
            
            let finalValue = baseValue + cycleValue + trendValue + noiseValue
            let clampedValue = max(10.0, min(120.0, finalValue))
            
            readings.append(Reading(date: currentDate, value: clampedValue))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            dayIndex += 1
        }
        
        return readings
    }
    
    static func normalRangeReadings() -> [Reading] {
        generateCyclicReadings(
            months: 6,
            baseValue: 42.0,
            cycleAmplitude: 8.0,
            cycleLength: 14,
            noise: 2.5,
            trend: 0.05
        )
    }
    
    static func highValueReadings() -> [Reading] {
        generateCyclicReadings(
            months: 5,
            baseValue: 78.0,
            cycleAmplitude: 12.0,
            cycleLength: 28,
            noise: 4.0,
            trend: 0.08
        )
    }
    
    static func defaultSettings() -> AppSettings {
        AppSettings(
            baselineMin: 35,
            baselineMax: 55,
            chartPeriod: "3M",
            chartScale: "D",
            smaWindow: 7
        )
    }
    
    @MainActor static func createPreviewContainer(with readings: [Reading], settings: AppSettings) -> ModelContainer {
        let container = try! ModelContainer(
            for: Reading.self, AppSettings.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        readings.forEach { container.mainContext.insert($0) }
        container.mainContext.insert(settings)
        try? container.mainContext.save()
        
        return container
    }
}