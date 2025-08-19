/** Requirements:
    - Color-coded badge showing performance zone
    - Use existing Pill component for consistent styling
    - Map performance categories to colors and labels
*/

import SwiftUI

// Note: This functionality is currently implemented in the existing Pill component
// and listTag function. This file serves as a placeholder for future classification
// badge enhancements if needed.

extension GuidanceCategory {
    var badgeColor: Color {
        switch self {
        case .below: return .red
        case .within: return .gray
        case .above: return .green
        }
    }
}