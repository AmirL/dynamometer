/** Requirements:
    - Calculate Y-axis domain with stable scaling
    - Determine visible chart data based on scroll position
    - Provide chart appearance and styling configuration
*/

import SwiftUI
import Foundation

struct ChartConfiguration {
    
    // MARK: - Y-Axis Domain Calculation
    
    static func calculateYDomain(
        chartData: [ChartDataPoint],
        settings: AppSettings,
        state: ChartState
    ) -> ClosedRange<Double> {
        let visibleData = visibleChartData(
            chartData: chartData,
            settings: settings,
            scrollPosition: state.scrollPosition
        )
        
        let visibleDataHash = createDataHash(from: visibleData)
        
        if let stableDomain = state.stableYDomain, 
           visibleDataHash == state.lastVisibleDataHash {
            return stableDomain
        }
        
        let values = visibleData.map(\.value)
        let smaValues = visibleData.compactMap(\.smaValue)
        let allVisibleValues = values + smaValues
        
        guard !allVisibleValues.isEmpty else {
            if let currentStableDomain = state.stableYDomain {
                return currentStableDomain
            }
            
            let minV = min(settings.baselineMin, settings.baselineMax) - 5
            let maxV = max(settings.baselineMin, settings.baselineMax) + 5
            let domain = minV...maxV
            state.updateStableDomain(domain, dataHash: visibleDataHash)
            return domain
        }
        
        let dataMin = allVisibleValues.min()!
        let dataMax = allVisibleValues.max()!
        let padding = 1.0
        
        let minV = min(dataMin - padding, settings.baselineMin - padding)
        let maxV = max(dataMax + padding, settings.baselineMax + padding)
        
        let domain = minV...maxV
        state.updateStableDomain(domain, dataHash: visibleDataHash)
        
        return domain
    }
    
    // MARK: - Visible Data Calculation
    
    static func visibleChartData(
        chartData: [ChartDataPoint],
        settings: AppSettings,
        scrollPosition: Date
    ) -> [ChartDataPoint] {
        guard !chartData.isEmpty else { return [] }
        
        let visibleDays: Double = {
            switch settings.chartPeriod {
            case "1M": return 30
            case "3M": return 90
            case "6M": return 180
            case "1Y": return 365
            case "All": return 90
            default: return 90
            }
        }()
        
        let visibleWidth = visibleDays * 86400
        let halfWidth = visibleWidth / 2
        let visibleStartDate = scrollPosition.addingTimeInterval(-halfWidth)
        let visibleEndDate = scrollPosition.addingTimeInterval(halfWidth)
        
        let visiblePoints = chartData.filter { point in
            point.date >= visibleStartDate && point.date <= visibleEndDate
        }
        
        if visiblePoints.isEmpty {
            let nearestPoint = chartData.min { 
                abs($0.date.timeIntervalSince(scrollPosition)) < abs($1.date.timeIntervalSince(scrollPosition)) 
            }
            return nearestPoint.map { [$0] } ?? []
        }
        
        return visiblePoints
    }
    
    // MARK: - Chart Styling
    
    static func baselineColor(for value: Double, settings: AppSettings) -> Color {
        if value < settings.baselineMin { return .red }
        if value > settings.baselineMax { return .green }
        return .gray
    }
    
    static var chartPlotBackground: some View {
        EmptyView()
            .background(.thinMaterial)
            .cornerRadius(12)
    }
    
    // MARK: - Private Helpers
    
    private static func createDataHash(from data: [ChartDataPoint]) -> Int {
        data.map { "\($0.date.timeIntervalSince1970)_\($0.value)" }
            .joined()
            .hashValue
    }
}