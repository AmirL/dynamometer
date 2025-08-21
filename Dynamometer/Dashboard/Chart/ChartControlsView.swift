/** Requirements:
    - Period selection controls (1M, 3M, 6M, 1Y, All)
    - Scale selection controls (Daily, Weekly)
    - Consistent styling with app theme
*/

import SwiftUI

struct ChartControlsView: View {
    let settings: AppSettings
    
    var body: some View {
        VStack(spacing: 12) {
            periodSelector
            scaleSelector
        }
        .padding(.bottom)
    }
    
    private var periodSelector: some View {
        Picker("Period", selection: Binding(
            get: { settings.chartPeriod },
            set: { settings.chartPeriod = $0 }
        )) {
            Text("1M").tag("1M")
            Text("3M").tag("3M")
            Text("6M").tag("6M")
            Text("1Y").tag("1Y")
            Text("All").tag("All")
        }
        .pickerStyle(.segmented)
        .tint(Theme.tint)
        .accessibilityIdentifier("period_segmented")
    }
    
    private var scaleSelector: some View {
        Picker("Scale", selection: Binding(
            get: { settings.chartScale },
            set: { settings.chartScale = $0 }
        )) {
            Text("Daily").tag("D")
            Text("Weekly").tag("W")
        }
        .pickerStyle(.segmented)
        .tint(Theme.tint)
        .accessibilityIdentifier("scale_segmented")
    }
}