import XCTest
@testable import Dynamometer

final class ChartLogicTests: XCTestCase {

    func testSMAWindow_Daily_All() {
        let base = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        let readings = (0..<7).map { i in
            Reading(date: base.addingTimeInterval(Double(i) * 86_400), value: Double(i + 1))
        }
        let points = readings.filteredByPeriod("All", scale: "D", smaWindow: 3)

        XCTAssertEqual(points.count, 7)
        XCTAssertNil(points[0].smaValue)
        XCTAssertNil(points[1].smaValue)
        XCTAssertEqual(points[2].smaValue!, (1 + 2 + 3) / 3.0, accuracy: 1e-6)
        XCTAssertEqual(points[3].smaValue!, (2 + 3 + 4) / 3.0, accuracy: 1e-6)
    }

    func testWeeklyAggregation_Basic() {
        let cal = Calendar.current
        let start = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        // Create readings across two weeks
        var readings: [Reading] = []
        for i in 0..<14 {
            let d = cal.date(byAdding: .day, value: i, to: start)!
            readings.append(Reading(date: d, value: Double(i + 1)))
        }
        let weekly = readings.filteredByPeriod("All", scale: "W", smaWindow: 3)
        XCTAssertGreaterThanOrEqual(weekly.count, 2)
        // Check ascending dates
        for i in 1..<weekly.count {
            XCTAssertLessThan(weekly[i-1].date, weekly[i].date)
        }
    }

    func testVisibleWidth_All_UsesDataSpanWithPadding() {
        let minDate = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        let maxDate = ISO8601DateFormatter().date(from: "2024-04-01T00:00:00Z")!
        let span = maxDate.timeIntervalSince(minDate)
        let width = ChartScaling.visibleWidth(period: "All", minDate: minDate, maxDate: maxDate)
        XCTAssertEqual(width, span * 1.04, accuracy: 1.0)
    }

    func testScrollDomain_RightAnchored_OneMonth() {
        let minDate = ISO8601DateFormatter().date(from: "2024-11-01T00:00:00Z")!
        let maxDate = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        let domain = ChartScaling.scrollDomain(minDate: minDate, maxDate: maxDate, period: "1M", hasInitialized: false)
        // End should be max; start should be max - 1M but clamped to min
        let oneMonthWidth = ChartScaling.visibleWidth(period: "1M", minDate: minDate, maxDate: maxDate)
        let expectedStart = maxDate.addingTimeInterval(-oneMonthWidth)
        XCTAssertEqual(domain.upperBound.timeIntervalSinceReferenceDate, maxDate.timeIntervalSinceReferenceDate, accuracy: 0.5)
        XCTAssertEqual(domain.lowerBound.timeIntervalSinceReferenceDate, Swift.max(expectedStart, minDate).timeIntervalSinceReferenceDate, accuracy: 0.5)
    }

    func testPaddedRange_Symmetric() {
        let minDate = ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!
        let maxDate = ISO8601DateFormatter().date(from: "2024-02-01T00:00:00Z")!
        let span = maxDate.timeIntervalSince(minDate)
        let range = ChartScaling.paddedRange(minDate: minDate, maxDate: maxDate, percent: 0.02)
        XCTAssertEqual(range.lowerBound, minDate.addingTimeInterval(-span * 0.02), accuracy: 0.5)
        XCTAssertEqual(range.upperBound, maxDate.addingTimeInterval( span * 0.02), accuracy: 0.5)
    }
}

private func XCTAssertEqual(_ lhs: Date, _ rhs: Date, accuracy: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(lhs.timeIntervalSinceReferenceDate, rhs.timeIntervalSinceReferenceDate, accuracy: accuracy, file: file, line: line)
}
