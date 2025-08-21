/** Requirements:
    - Chart showing grip strength over time
    - Scrollable with time period controls  
    - Show baseline corridor and trend line
    - Color points by performance zone
*/

import SwiftUI
import SwiftData
import Charts

struct ChartView: View {
    @Query(sort: \Reading.date) private var readings: [Reading]
    @Query private var settings: [AppSettings]
    @State private var scrollPosition: Date = .now
    @State private var hasInitialized = false
    @State private var stableYDomain: ClosedRange<Double>? = nil
    @State private var lastVisibleDataHash: Int = 0
    var chartHeight: CGFloat? = nil

    var body: some View {
        VStack(spacing: 16) {
            Group {
                if readings.isEmpty {
                    ContentUnavailableView("No Data", systemImage: "chart.xyaxis.line", description: Text("Add readings to see trends."))
                } else if let set = settings.first {
                    chart(readings: readings, settings: set, height: chartHeight)
                        .cardStyle()
                } else {
                    ContentUnavailableView("Configure Baseline", systemImage: "slider.horizontal.3", description: Text("Set baseline range in Settings."))
                }
            }

            if let set = settings.first, !readings.isEmpty {
                VStack(spacing: 12) {
                    periodSegmented(settings: set)
                    scaleSegmented(settings: set)
                }
                .padding(.bottom)
            }
        }
    }

    private func chart(readings: [Reading], settings: AppSettings, height: CGFloat?) -> some View {
        let allChartData = readings.filteredByPeriod("All", scale: settings.chartScale, smaWindow: settings.smaWindow)
        let minDate = allChartData.first?.date ?? .now
        let maxDate = allChartData.last?.date ?? .now
        
        return ZStack {
            Chart {
            // Baseline corridor band
            RectangleMark(
                xStart: .value("Start", minDate),
                xEnd: .value("End", maxDate),
                yStart: .value("Min", settings.baselineMin),
                yEnd: .value("Max", settings.baselineMax)
            )
            .foregroundStyle(.gray.opacity(0.10))

            // Boundary lines
            RuleMark(y: .value("Min", settings.baselineMin))
                .foregroundStyle(.secondary)
            RuleMark(y: .value("Max", settings.baselineMax))
                .foregroundStyle(.secondary)

            // Transparent raw data points
            ForEach(Array(allChartData.enumerated()), id: \.offset) { _, point in
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .symbolSize(28)
                .foregroundStyle(.primary.opacity(0.8))
            }
            
            // Thick SMA line
            ForEach(Array(allChartData.enumerated()), id: \.offset) { _, point in
                if let smaValue = point.smaValue {
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("SMA", smaValue)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(Theme.lineGradient)
                }
            }
            }
        }
        .accessibilityIdentifier("chart_container")
        .chartXScale(domain: scrollDomain(minDate: minDate, maxDate: maxDate, period: settings.chartPeriod))
        .chartYScale(domain: domainY(chartData: allChartData, settings: settings))
        .chartPlotStyle { area in
            area.background(.thinMaterial)
                .cornerRadius(12)
        }
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $scrollPosition)
        .chartXVisibleDomain(length: ChartScaling.visibleWidth(period: settings.chartPeriod, minDate: minDate, maxDate: maxDate))
        .onAppear {
            // Ensure we start scrolled to the most recent data (right side)
            if let last = allChartData.last?.date {
                DispatchQueue.main.async {
                    scrollPosition = last
                    hasInitialized = true
                }
            }
        }
        .onChange(of: settings.chartPeriod) { _, _ in
            // Reset initialization flag when changing zoom level to reposition
            hasInitialized = false
            stableYDomain = nil // Reset Y-axis scaling
            lastVisibleDataHash = 0
            if let last = allChartData.last?.date {
                DispatchQueue.main.async {
                    scrollPosition = last
                    hasInitialized = true
                }
            }
        }
        .onChange(of: readings.count) { _, _ in
            // When new readings arrive, keep view scrolled to the newest point
            stableYDomain = nil // Reset Y-axis scaling for new data
            lastVisibleDataHash = 0
            if let last = allChartData.last?.date {
                DispatchQueue.main.async {
                    scrollPosition = last
                }
            }
        }
        .onChange(of: settings.chartScale) { _, _ in
            // Reset Y-axis scaling when scale changes
            stableYDomain = nil
            lastVisibleDataHash = 0
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
        .frame(height: height ?? 220)
    }

    private func color(for value: Double, settings: AppSettings) -> Color {
        if value < settings.baselineMin { return .red }
        if value > settings.baselineMax { return .green }
        return .gray
    }

    private func domainY(chartData: [ChartDataPoint], settings: AppSettings) -> ClosedRange<Double> {
        let visibleData = visibleChartData(chartData: chartData, settings: settings)
        
        // Create a hash of the visible data to detect if it actually changed
        let visibleDataHash = visibleData.map { "\($0.date.timeIntervalSince1970)_\($0.value)" }.joined().hashValue
        
        // If the visible data hasn't changed, return the stable domain
        if let stableDomain = stableYDomain, visibleDataHash == lastVisibleDataHash {
            return stableDomain
        }
        
        let values = visibleData.map(\.value)
        let smaValues = visibleData.compactMap(\.smaValue)
        let allVisibleValues = values + smaValues
        
        guard !allVisibleValues.isEmpty else {
            // When no data is visible, keep the current stable domain if we have one
            // This prevents zoom-out when scrolling through empty periods
            if let currentStableDomain = stableYDomain {
                return currentStableDomain
            }
            
            // Fallback for initial load with no data
            let minV = min(settings.baselineMin, settings.baselineMax) - 5
            let maxV = max(settings.baselineMin, settings.baselineMax) + 5
            let domain = minV...maxV
            DispatchQueue.main.async {
                self.stableYDomain = domain
                self.lastVisibleDataHash = visibleDataHash
            }
            return domain
        }
        
        let dataMin = allVisibleValues.min()!
        let dataMax = allVisibleValues.max()!
        let dataRange = dataMax - dataMin
        
        // Add padding based on data range, minimum 2 units
        let padding = 1.0
        
        // Include baseline corridor in the range, but don't let it dominate
        let minV = min(dataMin - padding, settings.baselineMin - padding)
        let maxV = max(dataMax + padding, settings.baselineMax + padding)
        
        let domain = minV...maxV
        
        // Update stable domain asynchronously to avoid state updates during view updates
        DispatchQueue.main.async {
            self.stableYDomain = domain
            self.lastVisibleDataHash = visibleDataHash
        }
        
        return domain
    }
    
    private func visibleChartData(chartData: [ChartDataPoint], settings: AppSettings) -> [ChartDataPoint] {
        guard !chartData.isEmpty else { return [] }
        
        // Use a fixed visible window width instead of the period-based width
        // This ensures we only see data points actually visible on screen
        let visibleDays: Double = {
            switch settings.chartPeriod {
            case "1M": return 30
            case "3M": return 90 
            case "6M": return 180
            case "1Y": return 365
            case "All": return 90 // Use 3 months window even for "All" period
            default: return 90
            }
        }()
        
        let visibleWidth = visibleDays * 86400 // Convert days to seconds
        let halfWidth = visibleWidth / 2
        let visibleStartDate = scrollPosition.addingTimeInterval(-halfWidth)
        let visibleEndDate = scrollPosition.addingTimeInterval(halfWidth)
        
        // Filter to points within the visible window
        let visiblePoints = chartData.filter { point in
            point.date >= visibleStartDate && point.date <= visibleEndDate
        }
        
        // If no points are visible, return a small subset around scroll position
        if visiblePoints.isEmpty {
            let nearestPoint = chartData.min { abs($0.date.timeIntervalSince(scrollPosition)) < abs($1.date.timeIntervalSince(scrollPosition)) }
            return nearestPoint.map { [$0] } ?? []
        }
        
        return visiblePoints
    }
    
    private func periodSegmented(settings: AppSettings) -> some View {
        Picker("Period", selection: Binding(
            get: { settings.chartPeriod },
            set: { settings.chartPeriod = $0 }
        )) {
            Text("1M").tag("1M")
            Text("3M").tag("3M")
            Text("6M").tag("6M")
            Text("1Y").tag("1Y")
            Text("All").tag("All")
        }
        .pickerStyle(.segmented)
        .tint(Theme.tint)
        .accessibilityIdentifier("period_segmented")
    }

    private func scaleSegmented(settings: AppSettings) -> some View {
        Picker("Scale", selection: Binding(
            get: { settings.chartScale },
            set: { settings.chartScale = $0 }
        )) {
            Text("Daily").tag("D")
            Text("Weekly").tag("W")
        }
        .pickerStyle(.segmented)
        .tint(Theme.tint)
        .accessibilityIdentifier("scale_segmented")
    }
    
    
    private func scrollDomain(minDate: Date, maxDate: Date, period: String) -> ClosedRange<Date> {
        ChartScaling.scrollDomain(minDate: minDate, maxDate: maxDate, period: period, hasInitialized: hasInitialized)
    }
}

#Preview("Normal Range Data") {
    @Previewable @State var normalRangeReadings: [Reading] = ChartView.generateCyclicReadings(
        months: 6,
        baseValue: 42.0,
        cycleAmplitude: 8.0,
        cycleLength: 14,
        noise: 2.5,
        trend: 0.05
    )
    
    @Previewable @State var normalSettings = AppSettings(
        baselineMin: 35,
        baselineMax: 55,
        chartPeriod: "3M",
        chartScale: "D",
        smaWindow: 7
    )
    
    @Previewable @State var normalContainer = try! ModelContainer(
        for: Reading.self, AppSettings.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    ChartView()
        .modelContainer(normalContainer)
        .onAppear {
            normalRangeReadings.forEach { normalContainer.mainContext.insert($0) }
            normalContainer.mainContext.insert(normalSettings)
            try? normalContainer.mainContext.save()
        }
}

#Preview("High Values Data") {
    @Previewable @State var highValueReadings: [Reading] = ChartView.generateCyclicReadings(
        months: 5,
        baseValue: 78.0,
        cycleAmplitude: 12.0,
        cycleLength: 28,
        noise: 4.0,
        trend: 0.08
    )
    
    @Previewable @State var highSettings = AppSettings(
        baselineMin: 35,
        baselineMax: 55,
        chartPeriod: "3M",
        chartScale: "D",
        smaWindow: 7
    )
    
    @Previewable @State var highContainer = try! ModelContainer(
        for: Reading.self, AppSettings.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    ChartView()
        .modelContainer(highContainer)
        .onAppear {
            highValueReadings.forEach { highContainer.mainContext.insert($0) }
            highContainer.mainContext.insert(highSettings)
            try? highContainer.mainContext.save()
        }
}

// MARK: - Preview Data Seeding Helper

extension ChartView {
    static func generateCyclicReadings(
        months: Int = 4,
        baseValue: Double = 45.0,
        cycleAmplitude: Double = 15.0,
        cycleLength: Int = 21, // days per cycle
        noise: Double = 3.0,
        trend: Double = 0.1 // daily trend
    ) -> [Reading] {
        let calendar = Calendar.current
        let endDate = Date.now
        let startDate = calendar.date(byAdding: .month, value: -months, to: endDate)!
        
        var readings: [Reading] = []
        var currentDate = startDate
        var dayIndex = 0
        
        while currentDate <= endDate {
            // Cyclic component (sine wave)
            let cyclePhase = (Double(dayIndex % cycleLength) / Double(cycleLength)) * 2 * Double.pi
            let cycleValue = sin(cyclePhase) * cycleAmplitude
            
            // Trend component
            let trendValue = Double(dayIndex) * trend
            
            // Noise component
            let noiseValue = Double.random(in: -noise...noise)
            
            // Combine all components
            let finalValue = baseValue + cycleValue + trendValue + noiseValue
            
            // Ensure realistic values
            let clampedValue = max(10.0, min(120.0, finalValue))
            
            readings.append(Reading(date: currentDate, value: clampedValue))
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            dayIndex += 1
        }
        
        return readings
    }
}
