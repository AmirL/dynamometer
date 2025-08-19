/** Requirements:
    - Draw baseline corridor as light gray area
    - Add dashed lines for min/max boundaries
    - Use settings for corridor values
*/

import SwiftUI
import Charts

struct BaselineRenderer {
    static func baselineArea(settings: AppSettings, xRange: ClosedRange<Date>) -> some ChartContent {
        RectangleMark(
            xStart: .value("Start", xRange.lowerBound),
            xEnd: .value("End", xRange.upperBound),
            yStart: .value("Min", settings.baselineMin),
            yEnd: .value("Max", settings.baselineMax)
        )
        .foregroundStyle(.gray.opacity(0.2))
        .clipShape(Rectangle())
    }
    
    @ChartContentBuilder
    static func baselineBoundaries(settings: AppSettings, xRange: ClosedRange<Date>) -> some ChartContent {
        LineMark(
            x: .value("Date", xRange.lowerBound),
            y: .value("Min", settings.baselineMin)
        )
        .foregroundStyle(.gray.opacity(0.5))
        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
        
        LineMark(
            x: .value("Date", xRange.upperBound),
            y: .value("Max", settings.baselineMax)
        )
        .foregroundStyle(.gray.opacity(0.5))
        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
    }
}