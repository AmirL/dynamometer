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
        
        // Return stable domain if data hasn't changed
        if let stableDomain = getStableDomainIfUnchanged(state: state, dataHash: visibleDataHash) {
            return stableDomain
        }
        
        let domain = calculateDomainFromVisibleData(visibleData, settings: settings, state: state, dataHash: visibleDataHash)
        return domain
    }
    
    private static func getStableDomainIfUnchanged(
        state: ChartState,
        dataHash: Int
    ) -> ClosedRange<Double>? {
        guard let stableDomain = state.stableYDomain,
              dataHash == state.lastVisibleDataHash else {
            return nil
        }
        return stableDomain
    }
    
    private static func calculateDomainFromVisibleData(
        _ visibleData: [ChartDataPoint],
        settings: AppSettings,
        state: ChartState,
        dataHash: Int
    ) -> ClosedRange<Double> {
        let allVisibleValues = extractAllValues(from: visibleData)
        
        guard !allVisibleValues.isEmpty else {
            return handleEmptyData(settings: settings, state: state, dataHash: dataHash)
        }
        
        return createDomainFromValues(allVisibleValues, settings: settings, state: state, dataHash: dataHash)
    }
    
    private static func extractAllValues(from visibleData: [ChartDataPoint]) -> [Double] {
        let values = visibleData.map(\.value)
        let smaValues = visibleData.compactMap(\.smaValue)
        return values + smaValues
    }
    
    private static func handleEmptyData(
        settings: AppSettings,
        state: ChartState,
        dataHash: Int
    ) -> ClosedRange<Double> {
        if let currentStableDomain = state.stableYDomain {
            return currentStableDomain
        }
        
        let minV = min(settings.baselineMin, settings.baselineMax) - 5
        let maxV = max(settings.baselineMin, settings.baselineMax) + 5
        let domain = minV...maxV
        state.updateStableDomain(domain, dataHash: dataHash)
        return domain
    }
    
    private static func createDomainFromValues(
        _ allVisibleValues: [Double],
        settings: AppSettings,
        state: ChartState,
        dataHash: Int
    ) -> ClosedRange<Double> {
        guard let dataMin = allVisibleValues.min(),
              let dataMax = allVisibleValues.max() else {
            return handleEmptyData(settings: settings, state: state, dataHash: dataHash)
        }
        
        let padding = 1.0
        let minV = min(dataMin - padding, settings.baselineMin - padding)
        let maxV = max(dataMax + padding, settings.baselineMax + padding)
        
        let domain = minV...maxV
        state.updateStableDomain(domain, dataHash: dataHash)
        return domain
    }
    
    // MARK: - Visible Data Calculation
    
    static func visibleChartData(
        chartData: [ChartDataPoint],
        settings: AppSettings,
        scrollPosition: Date
    ) -> [ChartDataPoint] {
        guard !chartData.isEmpty else { return [] }
        
        let dateRange = calculateVisibleDateRange(for: settings.chartPeriod, scrollPosition: scrollPosition)
        print("visible date Range \(dateRange), scrollPosition: \(scrollPosition)")
        let visiblePoints = filterPointsInRange(chartData, dateRange: dateRange)
        
        guard visiblePoints.isEmpty else { return visiblePoints }
        
        return findNearestPoint(in: chartData, to: scrollPosition)
    }
    
    private static func calculateVisibleDateRange(
        for chartPeriod: String,
        scrollPosition: Date
    ) -> (start: Date, end: Date) {
        let visibleDays = getVisibleDaysForPeriod(chartPeriod)
        let visibleWidth = visibleDays * 86400
        let halfWidth = visibleWidth / 2
        
        let startDate = scrollPosition.addingTimeInterval(-halfWidth)
        let endDate = scrollPosition.addingTimeInterval(halfWidth)
        
        return (start: startDate, end: endDate)
    }
    
    private static func getVisibleDaysForPeriod(_ chartPeriod: String) -> Double {
        switch chartPeriod {
        case "1M": return 30
        case "3M": return 90
        case "6M": return 180
        case "1Y": return 365
        case "All": return 90
        default: return 90
        }
    }
    
    private static func filterPointsInRange(
        _ chartData: [ChartDataPoint],
        dateRange: (start: Date, end: Date)
    ) -> [ChartDataPoint] {
        return chartData.filter { point in
            point.date >= dateRange.start && point.date <= dateRange.end
        }
    }
    
    private static func findNearestPoint(
        in chartData: [ChartDataPoint],
        to scrollPosition: Date
    ) -> [ChartDataPoint] {
        guard let nearestPoint = chartData.min(by: { 
            abs($0.date.timeIntervalSince(scrollPosition)) < abs($1.date.timeIntervalSince(scrollPosition)) 
        }) else {
            return []
        }
        
        return [nearestPoint]
    }
    
    // MARK: - Chart Styling
    
    static func baselineColor(for value: Double, settings: AppSettings) -> Color {
        guard value >= settings.baselineMin else { return .red }
        guard value <= settings.baselineMax else { return .green }
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
