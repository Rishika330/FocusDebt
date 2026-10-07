import Foundation

/// Sample data for Demo mode only. Never loaded automatically in Live mode.
enum DemoData {

    static func scenario(
        goalMinutes: Int,
        calendar: Calendar = .current
    ) -> (activities: [DailyActivity], usage: [AppUsage]) {

        let goal = goalMinutes > 0 ? goalMinutes : 300

        // Oldest day first, today last
        let focusRatios: [Double] = [0.5, 0.8, 0.65, 0.9, 0.4, 0.7, 0.6]
        let distraction = [75, 40, 60, 30, 95, 50, 90]
        let interruptions = [3, 1, 2, 0, 5, 2, 4]

        var activities: [DailyActivity] = []
        for i in 0..<7 {
            let daysAgo = 6 - i
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            activities.append(
                DailyActivity(
                    date: date,
                    focusMinutes: Int(Double(goal) * focusRatios[i]),
                    distractionMinutes: distraction[i],
                    studyGoalMinutes: goal,
                    interruptions: interruptions[i]
                )
            )
        }

        // Today's usage adds up to today's 90 distraction minutes
        let usage = [
            AppUsage(appName: "YouTube", minutesUsed: 45, category: .entertainment, source: .simulated),
            AppUsage(appName: "Instagram", minutesUsed: 30, category: .social, source: .simulated),
            AppUsage(appName: "WhatsApp", minutesUsed: 15, category: .communication, source: .simulated)
        ]

        return (activities, usage)
    }
}
