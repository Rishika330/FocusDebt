import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static let brandBlue  = Color(hex: 0x0F4FA9)   // primary: buttons, accents
    static let brandCyan  = Color(hex: 0x0BA1D5)   // bright highlights
    static let brandTeal  = Color(hex: 0x1EACA6)   // secondary accents
    static let brandGreen = Color(hex: 0x20C96B)   // progress, goal reached
    static let brandNavy  = Color(hex: 0x123B7A)   // "Focus" text, headings
    static let brandGreenText = Color(hex: 0x14A25A) // "Debt" text (readable on light background)
    static let brandBackground = Color(red: 0.953, green: 0.973, blue: 0.992)
}
/// Highlights a button with the brand color while it is pressed.
struct AccentPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.brandBlue.opacity(configuration.isPressed ? 0.15 : 0))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.brandBlue, lineWidth: configuration.isPressed ? 2 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
