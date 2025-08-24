/** Requirements:
    - Render the main chart with baseline corridor and data points
    - Handle chart scrolling and axis configuration
    - Display SMA trend line with proper styling
*/

import SwiftUI
import Charts

struct ChartContentView: View {
    let chartData: [ChartDataPoint]
    let settings: AppSettings
    let state: ChartState
    let height: CGFloat?
    
    private var minDate: Date { chartData.first?.date ?? .now }
    private var maxDate: Date { 
        let lastDate = chartData.last?.date ?? .now
        let rightPadding: TimeInterval = 3 * 24 * 60 * 60 // 3 days in seconds
        return lastDate.addingTimeInterval(rightPadding)
    }
    
    var body: some View {
        ZStack {
            Chart {
                baselineCorridor
                boundaryLines
                dataPoints
                smaLine
            }
        }
        .accessibilityIdentifier("chart_container")
        .chartXScale(domain: scrollDomain)
        .chartYScale(domain: yDomain)
        .chartPlotStyle { area in
            area.background(.thinMaterial)
                .cornerRadius(12)
        }
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: Binding(
            get: { state.scrollPosition },
            set: { state.scrollPosition = $0 }
        ))
        .chartXVisibleDomain(length: ChartScaling.visibleWidth(
            period: settings.chartPeriod,
            minDate: minDate,
            maxDate: maxDate
        ))
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6))
        }
        .frame(height: height ?? 220)
        .onAppear {
            if let lastDate = chartData.last?.date {
                state.initializeScrollPosition(to: lastDate)
            }
        }
        .onChange(of: settings.chartPeriod) { _, _ in
            if let lastDate = chartData.last?.date {
                state.resetForPeriodChange(to: lastDate)
            }
        }
        .onChange(of: chartData.count) { _, _ in
            if let lastDate = chartData.last?.date {
                state.resetForNewData(to: lastDate)
            }
        }
        .onChange(of: settings.chartScale) { _, _ in
            state.resetForScaleChange()
        }
    }
    
    // MARK: - Chart Components
    
    private var baselineCorridor: some ChartContent {
        RectangleMark(
            xStart: .value("Start", minDate),
            xEnd: .value("End", maxDate),
            yStart: .value("Min", settings.baselineMin),
            yEnd: .value("Max", settings.baselineMax)
        )
        .foregroundStyle(.gray.opacity(0.10))
    }
    
    @ChartContentBuilder
    private var boundaryLines: some ChartContent {
        RuleMark(y: .value("Min", settings.baselineMin))
            .foregroundStyle(.secondary)
        RuleMark(y: .value("Max", settings.baselineMax))
            .foregroundStyle(.secondary)
    }
    
    private var dataPoints: some ChartContent {
        ForEach(Array(chartData.enumerated()), id: \.offset) { _, point in
            PointMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .symbolSize(28)
            .foregroundStyle(.primary.opacity(0.8))
        }
    }
    
    private var smaLine: some ChartContent {
        ForEach(Array(chartData.enumerated()), id: \.offset) { _, point in
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
    
    // MARK: - Computed Properties
    
    private var yDomain: ClosedRange<Double> {
        ChartConfiguration.calculateYDomain(
            chartData: chartData,
            settings: settings,
            state: state
        )
    }
    
    private var scrollDomain: ClosedRange<Date> {
        ChartScaling.scrollDomain(
            minDate: minDate,
            maxDate: maxDate,
            period: settings.chartPeriod
        )
    }
    
}