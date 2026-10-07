import Foundation

enum UsageSource: String, Codable {
    case manual
    case simulated
}

struct AppUsage: Identifiable, Codable {
    let id: UUID
    let appName: String
    let minutesUsed: Int
    let category: AppCategory
    let date: Date
    let source: UsageSource

    init(
        id: UUID = UUID(),
        appName: String,
        minutesUsed: Int,
        category: AppCategory,
        date: Date = Date(),
        source: UsageSource = .manual
    ) {
        self.id = id
        self.appName = appName
        self.minutesUsed = minutesUsed
        self.category = category
        self.date = date
        self.source = source
    }
}

enum AppCategory: String, Codable, CaseIterable, Identifiable {
    case study
    case communication
    case entertainment
    case social
    case other

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
