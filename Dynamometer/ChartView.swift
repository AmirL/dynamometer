import SwiftUI
import SwiftData
import Charts

struct ChartView: View {
    @Query(sort: \Reading.date) private var readings: [Reading]
    @Query private var settings: [AppSettings]
    @State private var scrollPosition: Date = .now
    @State private var hasInitialized = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Group {
                    if readings.isEmpty {
                        ContentUnavailableView("No Data", systemImage: "chart.xyaxis.line", description: Text("Add readings to see trends."))
                    } else if let set = settings.first {
                        chart(readings: readings, settings: set)
                            .cardStyle()
                    } else {
                        ContentUnavailableView("Configure Baseline", systemImage: "slider.horizontal.3", description: Text("Set baseline range in Settings."))
                    }
                }
                .navigationTitle("Trend")
                .padding(.horizontal)

                if let set = settings.first, !readings.isEmpty {
                    VStack(spacing: 12) {
                        periodSegmented(settings: set)
                        scaleSegmented(settings: set)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
        }
    }

    private func chart(readings: [Reading], settings: AppSettings) -> some View {
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
                .foregroundStyle(.primary.opacity(0.25))
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
            if let last = allChartData.last?.date {
                DispatchQueue.main.async {
                    scrollPosition = last
                    hasInitialized = true
                }
            }
        }
        .onChange(of: readings.count) { _, _ in
            // When new readings arrive, keep view scrolled to the newest point
            if let last = allChartData.last?.date {
                DispatchQueue.main.async {
                    scrollPosition = last
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
        .frame(minHeight: 220)
    }

    private func color(for value: Double, settings: AppSettings) -> Color {
        if value < settings.baselineMin { return .red }
        if value > settings.baselineMax { return .green }
        return .gray
    }

    private func domainY(chartData: [ChartDataPoint], settings: AppSettings) -> ClosedRange<Double> {
        let values = chartData.map(\.value)
        let smaValues = chartData.compactMap(\.smaValue)
        let allValues = values + smaValues
        
        let minV = min(allValues.min() ?? settings.baselineMin, settings.baselineMin) - 5
        let maxV = max(allValues.max() ?? settings.baselineMax, settings.baselineMax) + 5
        return minV...maxV
    }
    
    private func periodSegmented(settings: AppSettings) -> some View {
        Picker("Period", selection: Binding(
            get: { settings.chartPeriod },
            set: { settings.chartPeriod = $0 }
        )) {
            Text("1W").tag("1W")
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

// Removed custom period button and conditional view helper in favor of segmented controls

 
