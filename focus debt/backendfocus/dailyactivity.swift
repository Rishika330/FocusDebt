import Foundation

struct DailyActivity: Identifiable, Codable {
    let id: UUID
    let date: Date
    let focusMinutes: Int
    let distractionMinutes: Int
    let studyGoalMinutes: Int
    let interruptions: Int
    /// Seconds spent away from the app during focus sessions (tracked automatically)
    let awaySeconds: Int
    /// Leftover focus seconds (0-59) not yet rolled into focusMinutes
    let focusSeconds: Int
    
    // 1. Add this property to store individual interruption durations
        var interruptionLogs: [Int] = []

        
        
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        focusMinutes: Int,
        distractionMinutes: Int,
        studyGoalMinutes: Int,
        interruptions: Int,
        awaySeconds: Int = 0,
        focusSeconds: Int = 0,
        interruptionLogs: [Int] = []
    ) {
        self.id = id
        self.date = date
        self.focusMinutes = focusMinutes
        self.distractionMinutes = distractionMinutes
        self.studyGoalMinutes = studyGoalMinutes
        self.interruptions = interruptions
        self.awaySeconds = awaySeconds
        self.focusSeconds = focusSeconds
        self.interruptionLogs = interruptionLogs
    }

    // Custom decoding so data saved before the newer fields existed still loads
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        date = try c.decode(Date.self, forKey: .date)
        focusMinutes = try c.decode(Int.self, forKey: .focusMinutes)
        distractionMinutes = try c.decode(Int.self, forKey: .distractionMinutes)
        studyGoalMinutes = try c.decode(Int.self, forKey: .studyGoalMinutes)
        interruptions = try c.decode(Int.self, forKey: .interruptions)
        awaySeconds = try c.decodeIfPresent(Int.self, forKey: .awaySeconds) ?? 0
        focusSeconds = try c.decodeIfPresent(Int.self, forKey: .focusSeconds) ?? 0
    }

    /// Manually logged distraction plus time tracked away from the app
    var totalDistractionSeconds: Int {
        distractionMinutes * 60 + awaySeconds
    }

    /// Exact focus time
    var totalFocusSeconds: Int {
        focusMinutes * 60 + focusSeconds
    }
}
