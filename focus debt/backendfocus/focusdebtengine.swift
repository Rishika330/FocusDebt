import Foundation

struct FocusDebtEngine {

    static func calculateDebt(
        goalMinutes: Int,
        focusMinutes: Int
    ) -> Int {
        max(goalMinutes - focusMinutes, 0)
    }

    static func calculateDailyDebt(
        _ activity: DailyActivity
    ) -> Int {
        calculateDebt(
            goalMinutes: activity.studyGoalMinutes,
            focusMinutes: activity.focusMinutes
        )
    }

    static func calculateWeeklyDebt(
        _ activities: [DailyActivity]
    ) -> Int {
        activities.reduce(0) { total, activity in
            total + calculateDailyDebt(activity)
        }
    }

    static func calculateAverageDebt(
        _ activities: [DailyActivity]
    ) -> Int {

        guard !activities.isEmpty else {
            return 0
        }

        return calculateWeeklyDebt(activities) / activities.count
    }
}
