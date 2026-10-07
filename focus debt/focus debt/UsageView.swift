import SwiftUI
import Charts

struct UsageItem: Identifiable {
    var id: String { app }
    let app: String
    let minutes: Int
    let isSimulated: Bool
}

struct UsageView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showAdd = false

    private var isLive: Bool { dataManager.mode == .live }
    private var activity: DailyActivity { dataManager.todayActivity }
    private var showTracked: Bool { isLive || activity.awaySeconds > 0 }

    private var items: [UsageItem] {
        let grouped = Dictionary(grouping: dataManager.todayAppUsage) {
            $0.appName.lowercased()
        }
        return grouped.values.map { records in
            UsageItem(
                app: records[0].appName,
                minutes: records.reduce(0) { $0 + $1.minutesUsed },
                isSimulated: records.allSatisfy { $0.source == .simulated }
            )
        }
        .sorted { $0.minutes > $1.minutes }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Today's Usage")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(isLive
                     ? "Recorded automatically while you use Focus Debt. Other apps' usage is not read."
                     : "Entered manually or simulated. Focus Debt does not read other apps' usage automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if showTracked {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tracked in this app")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack {
                            Text("Time away during focus sessions")
                            Spacer()
                            Text(activity.awaySeconds.secondsAsDuration)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Times you left the app")
                            Spacer()
                            Text("\(activity.interruptions)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if items.isEmpty {
                    Text(isLive
                         ? "No other app usage to show. Time away from the app during focus sessions is tracked above."
                         : "No app usage logged yet. Tap + to add some.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                } else {
                    Chart(items) { item in
                        BarMark(
                            x: .value("Minutes", item.minutes),
                            y: .value("App", item.app)
                        )
                    }
                    .frame(height: max(120, CGFloat(items.count) * 50))

                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.app)
                                if item.isSimulated {
                                    Text("Simulated")
                                        .font(.caption2)
                                        .foregroundStyle(.orange)
                                }
                            }

                            Spacer()

                            Text("\(item.minutes) min")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Usage")
        .toolbar {
            if !isLive {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddAppUsageView().environmentObject(dataManager)
        }
    }
}

#Preview {
    NavigationStack {
        UsageView()
            .environmentObject(DataManager())
    }
}
