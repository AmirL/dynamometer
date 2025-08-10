import SwiftUI

struct Pill: View {
  let label: String
  let color: Color

  var body: some View {
    Text(label)
      .font(.caption).bold()
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(color.opacity(0.15))
      .foregroundStyle(color)
      .clipShape(Capsule())
  }
}

