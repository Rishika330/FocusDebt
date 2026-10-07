import SwiftUI

struct AnalysisView: View {

    @EnvironmentObject var dataManager: DataManager

    private struct InsightItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let icon: String
    }

    /// Every insight is computed from the logged-in user's saved history
    /// (demo scenario in Demo mode, real sessions in Live mode).
    private var insights: [InsightItem] {
        var items: [InsightItem] = []

        let today = dataManager.todayActivity
        let goal = today.studyGoalMinutes

        // Top distraction app today (only if the user logged app usage)
        let distractingUsage = dataManager.todayAppUsage.filter { $0.category != .study }
        var minutesByApp: [String: Int] = [:]
        for u in distractingUsage {
            minutesByApp[u.appName, default: 0] += u.minutesUsed
        }
        if let top = minutesByApp.max(by: { $0.value < $1.value }) {
            let total = distractingUsage.reduce(0) { $0 + $1.minutesUsed }
            items.append(InsightItem(
                title: "Top Distraction",
                message: "\(top.key) took \(top.value.asHoursMinutes) of your \(total.asHoursMinutes) logged distraction time today.",
                icon: "exclamationmark.triangle.fill"
            ))
        }

        // Interruptions and time away today
        if today.interruptions > 0 {
            let times = today.interruptions == 1 ? "1 time" : "\(today.interruptions) times"
            var message = "You were interrupted \(times) today."
            if today.awaySeconds > 0 {
                message += " You spent \(today.awaySeconds.secondsAsDuration) away from the app during focus sessions."
            }
            items.append(InsightItem(
                title: "Interruptions",
                message: message,
                icon: "bell.fill"
            ))
        }

        // Progress toward today's goal
        if goal > 0, today.focusMinutes > 0 {
            let percent = min(today.focusMinutes * 100 / goal, 100)
            items.append(InsightItem(
                title: "Today's Progress",
                message: "You've focused for \(today.focusMinutes.asHoursMinutes) of your \(goal.asHoursMinutes) goal (\(percent)%).",
                icon: "timer"
            ))
        }

        // History-based insights (need at least 3 days of data)
        let days = dataManager.activities.sorted { $0.date < $1.date }
        if days.count >= 3 {
            let last3 = days.suffix(3).map { FocusDebtEngine.calculateDailyDebt($0) }
            if last3[0] < last3[1] && last3[1] < last3[2] {
                items.append(InsightItem(
                    title: "Debt Trend",
                    message: "Your Focus Debt has increased for 3 days in a row.",
                    icon: "chart.line.uptrend.xyaxis"
                ))
            } else if last3[0] > last3[1] && last3[1] > last3[2] {
                items.append(InsightItem(
                    title: "Debt Trend",
                    message: "Your Focus Debt has dropped for 3 days in a row. Keep it up.",
                    icon: "chart.line.downtrend.xyaxis"
                ))
            }

            if let worst = days.max(by: { $0.totalDistractionSeconds < $1.totalDistractionSeconds }),
               worst.totalDistractionSeconds > 0 {
                let weekday = worst.date.formatted(.dateTime.weekday(.wide))
                items.append(InsightItem(
                    title: "Most Distracted Day",
                    message: "\(weekday) was your most distracted day, with \(worst.totalDistractionSeconds.secondsAsDuration) of distraction.",
                    icon: "calendar.badge.exclamationmark"
                ))
            }
        }

        return items
    }

    var body: some View {
        let items = insights

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                Text("Behavior Analysis")
                    .font(.title2)
                    .fontWeight(.bold)

                if items.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No insights yet")
                            .font(.headline)
                        Text("Complete a few focus sessions and your patterns will show up here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(items) { item in
                        InsightCard(
                            title: item.title,
                            message: item.message,
                            icon: item.icon
                        )
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Analysis")
    }
}

#Preview {
    NavigationStack {
        AnalysisView()
            .environmentObject(DataManager())
    }
}
