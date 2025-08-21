/** Requirements:
    - Display appropriate empty states for different scenarios
    - Handle no data and no settings cases
    - Provide clear user guidance
*/

import SwiftUI

struct ChartEmptyStateView: View {
    let emptyStateType: EmptyStateType
    
    enum EmptyStateType {
        case noData
        case noSettings
    }
    
    var body: some View {
        Group {
            switch emptyStateType {
            case .noData:
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.xyaxis.line",
                    description: Text("Add readings to see trends.")
                )
            case .noSettings:
                ContentUnavailableView(
                    "Configure Baseline",
                    systemImage: "slider.horizontal.3",
                    description: Text("Set baseline range in Settings.")
                )
            }
        }
    }
}