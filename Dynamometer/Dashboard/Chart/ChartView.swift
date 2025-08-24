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
    @State private var chartState = ChartState()
    var chartHeight: CGFloat? = nil

    var body: some View {
        VStack(spacing: 16) {
            chartContent
            chartControls
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        if let appSettings = settings.first, !readings.isEmpty {
            let chartData = readings.filteredByPeriod(
                "All",
                scale: appSettings.chartScale,
                smaWindow: appSettings.smaWindow
            )

            ChartContentView(
                chartData: chartData,
                settings: appSettings,
                state: chartState,
                height: chartHeight
            )
            .cardStyle()
        } else {
            ChartEmptyStateView(emptyStateType: .noData)
        }
    }

    @ViewBuilder
    private var chartControls: some View {
        if let appSettings = settings.first, !readings.isEmpty {
            ChartControlsView(settings: appSettings)
        }
    }


}

#Preview("Normal Range Data") {
    let readings = ChartPreviewData.normalRangeReadings()
    let settings = ChartPreviewData.defaultSettings()
    let container = ChartPreviewData.createPreviewContainer(with: readings, settings: settings)

    ChartView()
        .modelContainer(container)
}

#Preview("High Values Data") {
    let readings = ChartPreviewData.highValueReadings()
    let settings = ChartPreviewData.defaultSettings()
    let container = ChartPreviewData.createPreviewContainer(with: readings, settings: settings)

    ChartView()
        .modelContainer(container)
}

