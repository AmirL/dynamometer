import Foundation

enum ChartScaling {
    static func visibleWidth(period: String, minDate: Date, maxDate: Date) -> TimeInterval {
        let calendar = Calendar.current
        switch period {
        case "1W":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: maxDate)!.timeIntervalSince(maxDate)
        case "1M":
            return calendar.date(byAdding: .month, value: 1, to: maxDate)!.timeIntervalSince(maxDate)
        case "3M":
            return calendar.date(byAdding: .month, value: 3, to: maxDate)!.timeIntervalSince(maxDate)
        case "6M":
            return calendar.date(byAdding: .month, value: 6, to: maxDate)!.timeIntervalSince(maxDate)
        case "1Y":
            return calendar.date(byAdding: .year, value: 1, to: maxDate)!.timeIntervalSince(maxDate)
        case "All":
            // Real data span with 2% padding on both sides
            let span = maxDate.timeIntervalSince(minDate)
            return span * 1.04
        default:
            return calendar.date(byAdding: .month, value: 3, to: maxDate)!.timeIntervalSince(maxDate)
        }
    }

    static func paddedRange(minDate: Date, maxDate: Date, percent: Double) -> ClosedRange<Date> {
        let span = max(maxDate.timeIntervalSince(minDate), 1)
        let pad = span * max(percent, 0)
        let start = minDate.addingTimeInterval(-pad)
        let end = maxDate.addingTimeInterval(pad)
        return start...end
    }

    static func scrollDomain(minDate: Date, maxDate: Date, period: String, hasInitialized: Bool) -> ClosedRange<Date> {
        if period == "All" {
            return paddedRange(minDate: minDate, maxDate: maxDate, percent: 0.02)
        }
        if hasInitialized {
            return minDate...maxDate
        }
        let width = visibleWidth(period: period, minDate: minDate, maxDate: maxDate)
        let start = maxDate.addingTimeInterval(-width)
        return Swift.max(start, minDate)...maxDate
    }
}

