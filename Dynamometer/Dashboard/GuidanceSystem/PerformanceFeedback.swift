/** Requirements:
    - Generate encouraging feedback messages
    - Suggest actions based on performance
    - Personalize messages based on trend data
*/

import Foundation

struct PerformanceFeedback {
    static func message(for category: GuidanceCategory, trend: TrendDirection) -> String {
        switch (category, trend) {
        case (.above, .improving):
            return "Excellent! Your grip strength is above baseline and improving."
        case (.above, .stable):
            return "Great work! You're maintaining strength above your baseline."
        case (.above, .declining):
            return "Good strength level, but consider more consistent training."
        case (.within, .improving):
            return "Nice progress! You're moving toward stronger grip strength."
        case (.within, .stable):
            return "You're maintaining your baseline strength well."
        case (.within, .declining):
            return "Consider increasing training frequency to build strength."
        case (.below, .improving):
            return "Good progress! Keep up the consistent training."
        case (.below, .stable):
            return "Focus on consistent grip training to build strength."
        case (.below, .declining):
            return "Consider consulting a healthcare provider about your grip strength."
        }
    }
    
    static func actionSuggestion(for category: GuidanceCategory) -> String {
        switch category {
        case .above:
            return "Maintain your current routine"
        case .within:
            return "Consider progressive overload"
        case .below:
            return "Focus on consistent training"
        }
    }
}