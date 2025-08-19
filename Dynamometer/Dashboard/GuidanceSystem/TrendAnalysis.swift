/** Requirements:
    - Calculate trend direction from recent readings
    - Use moving averages for trend analysis
    - Provide trend strength indicators
*/

import Foundation

struct TrendAnalysis {
    static func calculateTrend(from readings: [Reading], window: Int = 7) -> TrendDirection {
        guard readings.count >= window * 2 else { return .stable }
        
        let recent = Array(readings.prefix(window))
        let previous = Array(readings.dropFirst(window).prefix(window))
        
        let recentAvg = recent.map(\.value).reduce(0, +) / Double(recent.count)
        let previousAvg = previous.map(\.value).reduce(0, +) / Double(previous.count)
        
        let difference = recentAvg - previousAvg
        let threshold = previousAvg * 0.05 // 5% change threshold
        
        if difference > threshold {
            return .improving
        } else if difference < -threshold {
            return .declining
        } else {
            return .stable
        }
    }
}

enum TrendDirection {
    case improving
    case declining
    case stable
    
    var description: String {
        switch self {
        case .improving: return "Improving"
        case .declining: return "Declining"
        case .stable: return "Stable"
        }
    }
}