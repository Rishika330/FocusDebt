import Foundation

struct FocusScoreEngine {

    static func calculateScore(
        goalMinutes: Int,
        focusMinutes: Int
    ) -> Int {

        guard goalMinutes > 0 else {
            return 0
        }

        let ratio =
            Double(focusMinutes) /
            Double(goalMinutes)

        return min(
            Int(ratio * 100),
            100
        )
    }

    static func calculateScore(
        _ activity: DailyActivity
    ) -> Int {

        calculateScore(
            goalMinutes: activity.studyGoalMinutes,
            focusMinutes: activity.focusMinutes
        )
    }
}

