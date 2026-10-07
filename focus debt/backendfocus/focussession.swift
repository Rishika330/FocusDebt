import Foundation
import SwiftData

@Model
final class FocusSession {

    @Attribute(.unique)
    var id: UUID

    var startTime: Date
    var duration: TimeInterval
    var completed: Bool

    init(
        id: UUID = UUID(),
        startTime: Date,
        duration: TimeInterval,
        completed: Bool
    ) {
        self.id = id
        self.startTime = startTime
        self.duration = duration
        self.completed = completed
    }

    var durationMinutes: Int {
        max(Int(duration / 60), 0)
    }
}

