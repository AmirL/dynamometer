/** Requirements:
    - Manage chart scroll position and initialization state
    - Track Y-axis domain stability to prevent unwanted scaling
    - Handle chart state updates for period and data changes
*/

import SwiftUI
import Foundation

@Observable
class ChartState {
    var scrollPosition: Date = .now
    var stableYDomain: ClosedRange<Double>? = nil
    var lastVisibleDataHash: Int = 0
    
    func resetForPeriodChange(to lastDate: Date, visibleWidth: TimeInterval) {
        stableYDomain = nil
        lastVisibleDataHash = 0
        // Position the scroll to show recent data with some future space on the right
        let futureSpace = visibleWidth * 0.3
        scrollPosition = lastDate.addingTimeInterval(futureSpace - visibleWidth)
    }
    
    func resetForNewData(to lastDate: Date, visibleWidth: TimeInterval) {
        stableYDomain = nil
        lastVisibleDataHash = 0
        // Position the scroll so lastDate appears near the right side (80% of visible width from left edge)
        scrollPosition = lastDate.addingTimeInterval(-visibleWidth * 0.8)
    }
    
    func resetForScaleChange() {
        stableYDomain = nil
        lastVisibleDataHash = 0
    }
    
    func initializeScrollPosition(to lastDate: Date, visibleWidth: TimeInterval) {
        // Position the scroll to show recent data with some future space on the right
        // lastDate should be at about 70% of the visible width, leaving 30% for future data
        let futureSpace = visibleWidth * 0.3
        scrollPosition = lastDate.addingTimeInterval(futureSpace - visibleWidth)
    }
    
    func updateStableDomain(_ domain: ClosedRange<Double>, dataHash: Int) {
        DispatchQueue.main.async {
            self.stableYDomain = domain
            self.lastVisibleDataHash = dataHash
        }
    }
}