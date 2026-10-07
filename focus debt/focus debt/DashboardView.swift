import SwiftUI

private enum DashboardSheet: Identifiable {
    case activity, usage, simulate
    var id: String { String(describing: self) }
}

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var activeSheet: DashboardSheet?

    private var activity: DailyActivity { dataManager.todayActivity }
    private var goal: Int { activity.studyGoalMinutes }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    // MARK: - Updated Dynamic Severity Calculation
    private var severity: (label: String, color: Color) {
        guard goal > 0 else { return ("Set a goal", .secondary) }
        
        // Normalize debt to minutes if passed in seconds
        let rawDebt = Double(dataManager.todayFocusDebt)
        let debtInMinutes = rawDebt > Double(goal * 2) ? rawDebt / 60.0 : rawDebt
        
        let ratio = debtInMinutes / Double(goal)
        
        if ratio <= 0 {
            return ("Goal reached", Color.brandGreen)
        } else if ratio <= 0.25 {
            return ("Low", Color.brandGreen)
        } else if ratio <= 0.6 {
            return ("Moderate", .orange)
        } else {
            return ("High", .red)
        }
    }

    private var progress: Double {
        goal > 0
            ? min(max(Double(activity.totalFocusSeconds) / Double(goal * 60), 0), 1)
            : 0
    }

    private var isEmpty: Bool {
        activity.totalFocusSeconds == 0
        && activity.totalDistractionSeconds == 0
        && dataManager.todayAppUsage.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 5) {
                        let name = dataManager.student.name
                        Text(name.isEmpty ? greeting : "\(greeting), \(name)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Here's your focus overview.")
                            .foregroundStyle(.secondary)
                    }

                    // MARK: Mode
                    Picker("Mode", selection: Binding(
                        get: { dataManager.mode },
                        set: { dataManager.setMode($0) }
                    )) {
                        Text("Live").tag(AppMode.live)
                        Text("Demo").tag(AppMode.demo)
                    }
                    .pickerStyle(.segmented)

                    if dataManager.mode == .demo {
                        Label("DEMO MODE: sample data, not real activity", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color.orange.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // MARK: Focus Debt
                    VStack(spacing: 8) {
                        Text("Today's Focus Debt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(dataManager.todayFocusDebt.asHoursMinutes)
                            .font(.system(size: 44, weight: .bold))

                        Text(severity.label)
                            .font(.subheadline)
                            .foregroundStyle(severity.color)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .background(Color.brandBlue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                    if isEmpty {
                        Text(dataManager.mode == .live
                             ? "No activity yet. Start a focus session to see your Focus Debt change."
                             : "No activity yet. Add some activity or simulate usage to see your Focus Debt change.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: Focus Progress
                    ProgressCard(
                        title: "Today's Focus",
                        current: activity.totalFocusSeconds.secondsAsDuration,
                        target: goal.asHoursMinutes,
                        progress: progress
                    )

                    // MARK: Metrics
                    HStack(spacing: 14) {
                        MetricCard(
                            title: "Focus Score",
                            value: "\(dataManager.todayFocusScore)",
                            subtitle: "Out of 100",
                            icon: "brain.head.profile"
                        )

                        MetricCard(
                            title: "Distraction",
                            value: dataManager.todayDistractionSeconds.secondsAsDuration,
                            subtitle: "Logged today",
                            icon: "iphone"
                        )
                    }

                    // MARK: Insight
                    InsightCard(
                        title: "Today's Insight",
                        message: dataManager.todayInsight,
                        icon: "lightbulb.fill"
                    )

                    // MARK: Main Actions
                    VStack(spacing: 12) {

                        NavigationLink {
                            FocusSessionView()
                        } label: {
                            ActionButton(
                                title: "Start Focus Session",
                                icon: "play.fill"
                            )
                        }
                        .buttonStyle(AccentPressStyle())

                        if dataManager.mode == .demo {
                            Button { activeSheet = .activity } label: {
                                SecondaryActionButton(
                                    title: "Add Today's Activity",
                                    icon: "square.and.pencil"
                                )
                            }
                            .buttonStyle(AccentPressStyle())

                            Button { activeSheet = .usage } label: {
                                SecondaryActionButton(
                                    title: "Add App Usage",
                                    icon: "plus.app"
                                )
                            }
                            .buttonStyle(AccentPressStyle())

                            Button { activeSheet = .simulate } label: {
                                SecondaryActionButton(
                                    title: "Simulate Usage (Demo)",
                                    icon: "bolt.fill"
                                )
                            }
                            .buttonStyle(AccentPressStyle())
                        }

                        NavigationLink {
                            UsageView()
                        } label: {
                            SecondaryActionButton(
                                title: "View Usage",
                                icon: "chart.bar.fill"
                            )
                        }
                        .buttonStyle(AccentPressStyle())
                        
                        NavigationLink {
                            AppListView()
                        } label: {
                            SecondaryActionButton(
                                title: "Manage Apps",
                                icon: "square.grid.2x2"
                            )
                        }
                        .buttonStyle(AccentPressStyle())

                        NavigationLink {
                            AnalysisView()
                        } label: {
                            SecondaryActionButton(
                                title: "Behavior Analysis",
                                icon: "brain.head.profile"
                            )
                        }
                        .buttonStyle(AccentPressStyle())

                        NavigationLink {
                            WeeklyReportView()
                        } label: {
                            SecondaryActionButton(
                                title: "Weekly Report",
                                icon: "chart.xyaxis.line"
                            )
                        }
                        .buttonStyle(AccentPressStyle())
                    }
                }
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Focus").foregroundStyle(Color.brandNavy)
                        Text("Debt").foregroundStyle(Color.brandGreenText)
                    }
                    .font(.system(.title2, design: .rounded, weight: .heavy))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                }
            }            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .activity:
                    AddActivityView().environmentObject(dataManager)
                case .usage:
                    AddAppUsageView().environmentObject(dataManager)
                case .simulate:
                    SimulateEventView().environmentObject(dataManager)
                }
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title).fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.brandBlue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SecondaryActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon).frame(width: 25)
            Text(title).fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
}
