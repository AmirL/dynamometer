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
            VStack(spacing: 8) {
                Group {
                    if readings.isEmpty {
                        ContentUnavailableView("No Data", systemImage: "chart.xyaxis.line", description: Text("Add readings to see trends."))
                    } else if let set = settings.first {
                        chart(readings: readings, settings: set)
                    } else {
                        ContentUnavailableView("Configure Baseline", systemImage: "slider.horizontal.3", description: Text("Set baseline range in Settings."))
                    }
                }
                .navigationTitle("Trend")
                .padding()

                if let set = settings.first, !readings.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        periodSelector(settings: set)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
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
            .foregroundStyle(.gray.opacity(0.12))

            // Boundary lines
            RuleMark(y: .value("Min", settings.baselineMin))
                .foregroundStyle(.gray.opacity(0.5))
            RuleMark(y: .value("Max", settings.baselineMax))
                .foregroundStyle(.gray.opacity(0.5))

            // Transparent raw data points
            ForEach(Array(allChartData.enumerated()), id: \.offset) { _, point in
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .symbolSize(30)
                .foregroundStyle(.blue.opacity(0.3))
            }
            
            // Thick SMA line
            ForEach(Array(allChartData.enumerated()), id: \.offset) { _, point in
                if let smaValue = point.smaValue {
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("SMA", smaValue)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(.blue)
                }
            }
            }
        }
        .accessibilityIdentifier("chart_container")
        .chartXScale(domain: scrollDomain(minDate: minDate, maxDate: maxDate, period: settings.chartPeriod))
        .chartYScale(domain: domainY(chartData: allChartData, settings: settings))
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
    
    private func periodSelector(settings: AppSettings) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                PeriodButton(title: "1W", isSelected: settings.chartPeriod == "1W", settings: settings)
                PeriodButton(title: "1M", isSelected: settings.chartPeriod == "1M", settings: settings)
                PeriodButton(title: "3M", isSelected: settings.chartPeriod == "3M", settings: settings)
                PeriodButton(title: "6M", isSelected: settings.chartPeriod == "6M", settings: settings)
                PeriodButton(title: "1Y", isSelected: settings.chartPeriod == "1Y", settings: settings)
                PeriodButton(title: "All", isSelected: settings.chartPeriod == "All", settings: settings)
                
                Menu {
                    Button(settings.chartScale == "D" ? "Daily ✓" : "Daily") {
                        settings.chartScale = "D"
                    }
                    Button(settings.chartScale == "W" ? "Weekly ✓" : "Weekly") {
                        settings.chartScale = "W"
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(settings.chartScale)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    
    private func scrollDomain(minDate: Date, maxDate: Date, period: String) -> ClosedRange<Date> {
        ChartScaling.scrollDomain(minDate: minDate, maxDate: maxDate, period: period, hasInitialized: hasInitialized)
    }
}

struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let settings: AppSettings
    
    var body: some View {
        Button(title) {
            settings.chartPeriod = title
        }
        .accessibilityIdentifier("period_\(title.lowercased())")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minWidth: 36)
        .background(isSelected ? Color.black : Color(.systemGray5))
        .clipShape(Capsule())
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

 
