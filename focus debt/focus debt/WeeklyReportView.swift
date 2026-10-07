import SwiftUI
import Charts

struct WeeklyReportView: View {

    @EnvironmentObject var dataManager: DataManager
    private let calendar = Calendar.current

    private struct DayStat: Identifiable {
        let id = UUID()
        let label: String
        let focusMinutes: Int
        let debtMinutes: Int
        let hasData: Bool
    }

    /// Last 7 days ending today, built from the logged-in user's saved history.
    private var week: [DayStat] {
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            let entry = dataManager.activities.last {
                calendar.isDate($0.date, inSameDayAs: day)
            }
            return DayStat(
                label: day.formatted(.dateTime.weekday(.abbreviated)),
                focusMinutes: entry?.focusMinutes ?? 0,
                debtMinutes: entry.map { FocusDebtEngine.calculateDailyDebt($0) } ?? 0,
                hasData: entry != nil
            )
        }
    }

    var body: some View {
        let days = week
        let logged = days.filter { $0.hasData }

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Text("Weekly Focus")
                    .font(.title2)
                    .fontWeight(.bold)

                if logged.isEmpty {
                    emptyState
                } else {
                    Chart(days) { item in
                        BarMark(
                            x: .value("Day", item.label),
                            y: .value("Hours", Double(item.focusMinutes) / 60)
                        )
                    }
                    .frame(height: 260)

                    HStack(spacing: 14) {
                        MetricCard(
                            title: "Average Focus",
                            value: averageText(logged.map(\.focusMinutes)),
                            subtitle: "Per logged day",
                            icon: "clock"
                        )

                        MetricCard(
                            title: "Average Debt",
                            value: averageText(logged.map(\.debtMinutes)),
                            subtitle: "Per logged day",
                            icon: "exclamationmark.clock"
                        )
                    }

                    InsightCard(
                        title: "Weekly Insight",
                        message: insight(from: logged),
                        icon: "star.fill"
                    )
                }
            }
            .padding(20)
        }
        .navigationTitle("Weekly Report")
    }

    // MARK: - Pieces

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No history yet")
                .font(.headline)
            Text("Complete a focus session and your week will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func averageText(_ minutes: [Int]) -> String {
        guard !minutes.isEmpty else { return "0m" }
        return (minutes.reduce(0, +) / minutes.count).asHoursMinutes
    }

    private func insight(from logged: [DayStat]) -> String {
        var parts: [String] = []
        if logged.count >= 2, let best = logged.max(by: { $0.focusMinutes < $1.focusMinutes }) {
            parts.append("\(best.label) was your strongest focus day with \(best.focusMinutes.asHoursMinutes).")
        }
        parts.append(dataManager.weeklyInsight)
        return parts.joined(separator: " ")
    }
}

#Preview {
    NavigationStack {
        WeeklyReportView()
            .environmentObject(DataManager())
    }
}
