import SwiftUI

enum Theme {
  static let tint: Color = .indigo

  static let lineGradient: LinearGradient = .linearGradient(
    colors: [.indigo, .blue],
    startPoint: .leading,
    endPoint: .trailing
  )

  static let backgroundGradient: LinearGradient = .linearGradient(
    colors: [
      Color(.systemGroupedBackground),
      Color(.systemBackground)
    ],
    startPoint: .top,
    endPoint: .bottom
  )
}

private struct CardModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(16)
      .background(
        .ultraThinMaterial,
        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .strokeBorder(Color.black.opacity(0.06))
      )
  }
}

extension View {
  func cardStyle() -> some View { modifier(CardModifier()) }
}

