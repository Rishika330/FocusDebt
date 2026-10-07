import Foundation

struct BehaviorAnalyzer {

    // MARK: - Daily insight

    static func generateInsight(
        activity: DailyActivity,
        appUsage: [AppUsage]
    ) -> String {

        let goal = activity.studyGoalMinutes
        guard goal > 0 else {
            return "Set a daily study goal to start getting insights."
        }

        let hasData = activity.focusMinutes > 0
            || activity.totalDistractionSeconds > 0
            || activity.interruptions > 0
            || !appUsage.isEmpty
        guard hasData else {
            return "No activity yet today. Start a focus session to see insights."
        }

        let debt = max(goal - activity.focusMinutes, 0)
        if debt == 0 {
            return "Great work. You reached your study goal today."
        }

        let distractionMinutes = activity.totalDistractionSeconds / 60

        // Biggest non-study app among today's logged usage
        var minutesByApp: [String: Int] = [:]
        var displayName: [String: String] = [:]
        var allSimulated: [String: Bool] = [:]

        for record in appUsage where record.category != .study {
            let key = record.appName.lowercased()
            minutesByApp[key, default: 0] += record.minutesUsed
            displayName[key] = displayName[key] ?? record.appName
            allSimulated[key] = (allSimulated[key] ?? true) && record.source == .simulated
        }

        if let topKey = minutesByApp.max(by: { $0.value < $1.value })?.key,
           let topMinutes = minutesByApp[topKey],
           topMinutes >= 15 {

            var name = displayName[topKey] ?? topKey
            if allSimulated[topKey] == true { name += " (simulated)" }

            if distractionMinutes >= debt {
                return "Your Focus Debt is \(debt.asHoursMinutes). Your logged distraction time (\(distractionMinutes.asHoursMinutes)), led by \(name) at \(topMinutes.asHoursMinutes), is at least as large as your debt, so reclaiming that time could cover all of it."
            }
            return "Your Focus Debt is \(debt.asHoursMinutes). The biggest distraction you logged was \(name) at \(topMinutes.asHoursMinutes)."
        }

        // Detailed session interruptions analysis using individual interruption logs
        if !activity.interruptionLogs.isEmpty {
            let count = activity.interruptionLogs.count
            let totalAway = activity.awaySeconds
            let avgSeconds = totalAway / max(count, 1)
            let longestSeconds = activity.interruptionLogs.max() ?? 0
            let times = count == 1 ? "1 time" : "\(count) times"

            return "You left the app \(times) during sessions for \(totalAway.secondsAsDuration) total away (avg: \(avgSeconds.secondsAsDuration), longest: \(longestSeconds.secondsAsDuration)). Your Focus Debt is \(debt.asHoursMinutes). Try putting your phone out of reach during your next session."
        }

        // Fallback for legacy tracking (if interruptionLogs array is empty)
        if activity.interruptions > 0 && activity.awaySeconds > 0 {
            let times = activity.interruptions == 1 ? "1 time" : "\(activity.interruptions) times"
            return "You left the app \(times) during focus sessions and spent \(activity.awaySeconds.secondsAsDuration) away. Your Focus Debt is \(debt.asHoursMinutes). Try putting your phone out of reach during your next session."
        }

        if activity.interruptions >= 3 {
            return "You were interrupted \(activity.interruptions) times and still have \(debt.asHoursMinutes) of Focus Debt. Try putting your phone out of reach during your next session."
        }

        if Double(activity.focusMinutes) / Double(goal) >= 0.5 {
            return "You've completed \(activity.focusMinutes.asHoursMinutes) of your \(goal.asHoursMinutes) goal. One more focused session would close most of the remaining \(debt.asHoursMinutes)."
        }

        return "You've completed \(activity.focusMinutes.asHoursMinutes) of your \(goal.asHoursMinutes) goal. Start with one short focus session to begin reducing your Focus Debt."
    }

    // MARK: - Weekly insight

    static func generateWeeklyInsight(
        activities: [DailyActivity]
    ) -> String {

        guard !activities.isEmpty else {
            return "Not enough data to generate a weekly insight."
        }

        let totalFocus = activities.reduce(0) { $0 + $1.focusMinutes }
        let totalGoal = activities.reduce(0) { $0 + $1.studyGoalMinutes }
        let allLogs = activities.flatMap { $0.interruptionLogs }

        if totalFocus >= totalGoal {
            if !allLogs.isEmpty {
                let avgDuration = allLogs.reduce(0, +) / allLogs.count
                return "You reached your overall weekly focus goal! You had \(allLogs.count) total session exits this week averaging \(avgDuration.secondsAsDuration) each."
            }
            return "You reached your overall weekly focus goal. Keep building consistency."
        }

        let debt = FocusDebtEngine.calculateWeeklyDebt(activities)

        if !allLogs.isEmpty {
            let totalCount = allLogs.count
            let avgDuration = allLogs.reduce(0, +) / totalCount
            return "Your weekly Focus Debt is \(debt.asHoursMinutes). Across your sessions, you had \(totalCount) interruptions averaging \(avgDuration.secondsAsDuration) per exit."
        }

        if debt > 300 {
            return "Your weekly focus debt is high (\(debt.asHoursMinutes)). Try scheduling smaller, consistent focus sessions."
        }

        return "Your focus is improving. Consistency across the week can help reduce your focus debt."
    }
}
