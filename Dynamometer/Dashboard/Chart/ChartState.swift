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
    
    func resetForPeriodChange(to newScrollPosition: Date) {
        stableYDomain = nil
        lastVisibleDataHash = 0
        scrollPosition = newScrollPosition
    }
    
    func resetForNewData(to newScrollPosition: Date) {
        stableYDomain = nil
        lastVisibleDataHash = 0
        scrollPosition = newScrollPosition
    }
    
    func resetForScaleChange() {
        stableYDomain = nil
        lastVisibleDataHash = 0
    }
    
    func initializeScrollPosition(to position: Date) {
        scrollPosition = position
    }
    
    func updateStableDomain(_ domain: ClosedRange<Double>, dataHash: Int) {
        DispatchQueue.main.async {
            self.stableYDomain = domain
            self.lastVisibleDataHash = dataHash
        }
    }
}