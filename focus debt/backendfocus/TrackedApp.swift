import Foundation

struct TrackedApp: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var isProductive: Bool

    static let defaults: [TrackedApp] = [
        TrackedApp(name: "Notes", isProductive: true),
        TrackedApp(name: "Reminders", isProductive: true),
        TrackedApp(name: "Safari", isProductive: false),
        TrackedApp(name: "YouTube", isProductive: false),
        TrackedApp(name: "Instagram", isProductive: false),
        TrackedApp(name: "WhatsApp", isProductive: false)
    ]
}
