import SwiftUI
import Combine

struct FocusSessionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.scenePhase) private var scenePhase

    @State private var durationSeconds = 25 * 60
    @State private var secondsRemaining = 25 * 60
    @State private var isRunning = false
    @State private var endDate: Date?
    @State private var leftAt: Date?
    @State private var interruptions = 0
    @State private var awaySeconds = 0             // distraction time
    @State private var productiveAwaySeconds = 0   // away time spent in productive apps
    @State private var pendingAwaySeconds = 0      // waiting for the user to pick an app
    @State private var showAwaySheet = false
    @State private var sessionEndedWhileAsking = false
    @State private var summary: SessionSummary?
    @State private var customMinutes = ""

    private struct SessionSummary {
        let seconds: Int
        let interruptions: Int
        let awaySeconds: Int
        let productiveAwaySeconds: Int
    }

    private let presets: [(label: String, seconds: Int)] = [
        ("30 sec test", 30),
        ("5 min", 5 * 60),
        ("15 min", 15 * 60),
        ("25 min", 25 * 60),
        ("45 min", 45 * 60),
        ("60 min", 60 * 60)
    ]

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    private var customValue: Int? {
        guard let value = Int(customMinutes), (1...480).contains(value) else { return nil }
        return value
    }

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Text("FOCUS SESSION")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(timeString)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()

            statusSection

            if !isRunning {
                durationSection
            }

            Spacer()

            Button {
                isRunning ? pause() : start()
            } label: {
                Text(isRunning ? "Pause" : (secondsRemaining < durationSeconds ? "Resume" : "Start"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(isRunning ? Color.orange : Color.brandBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                reset()
            } label: {
                Text("Reset Session")
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Focus Session")
        .onReceive(timer) { _ in tick() }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background:
                if isRunning && leftAt == nil {
                    leftAt = Date()
                    interruptions += 1
                    dataManager.logInterruption()
                }
            case .active:
                recordAwayTime()
                tick()
            default:
                break
            }
        }
        .sheet(isPresented: $showAwaySheet, onDismiss: { resolveAway(nil) }) {
            AwaySheet(seconds: pendingAwaySeconds) { resolveAway($0) }
                .environmentObject(dataManager)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        VStack(spacing: 6) {
            Text(isRunning ? "Stay in the app until the timer ends." : "Ready when you are.")
                .foregroundStyle(.secondary)

            if interruptions > 0 {
                Text("Left the app \(interruptions)x, \(awaySeconds.secondsAsDuration) distracted")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }

            if let summary {
                VStack(spacing: 4) {
                    Text("Session complete. \(summary.seconds.secondsAsDuration) added to your focus time.")
                        .foregroundStyle(.green)

                    if summary.interruptions > 0 {
                        let times = summary.interruptions == 1 ? "1 time" : "\(summary.interruptions) times"
                        Text("You left the app \(times).")
                            .foregroundStyle(.secondary)

                        if summary.awaySeconds > 0 {
                            Text("\(summary.awaySeconds.secondsAsDuration) was added to your distraction.")
                                .foregroundStyle(.orange)
                        }
                        if summary.productiveAwaySeconds > 0 {
                            Text("\(summary.productiveAwaySeconds.secondsAsDuration) in productive apps stayed as focus time.")
                                .foregroundStyle(Color.brandGreenText)
                        }
                    } else {
                        Text("No interruptions.")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var durationSection: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.seconds) { preset in
                        Button {
                            setDuration(preset.seconds)
                        } label: {
                            Text(preset.label)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(durationSeconds == preset.seconds ? .white : .primary)
                                .background(durationSeconds == preset.seconds ? Color.brandBlue : Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack {
                TextField("Custom minutes (1-480)", text: $customMinutes)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Set") {
                    if let minutes = customValue {
                        setDuration(minutes * 60)
                        customMinutes = ""
                    }
                }
                .disabled(customValue == nil)
            }
        }
    }

    // MARK: - Timer logic

    private func setDuration(_ seconds: Int) {
        durationSeconds = seconds
        reset()
    }

    private func start() {
        if secondsRemaining == durationSeconds {
            interruptions = 0
            awaySeconds = 0
            productiveAwaySeconds = 0
            pendingAwaySeconds = 0
        }
        summary = nil
        endDate = Date().addingTimeInterval(TimeInterval(secondsRemaining))
        isRunning = true
    }

    private func pause() {
        tick()
        isRunning = false
        endDate = nil
        leftAt = nil
    }

    private func reset() {
        isRunning = false
        endDate = nil
        leftAt = nil
        interruptions = 0
        awaySeconds = 0
        productiveAwaySeconds = 0
        pendingAwaySeconds = 0
        showAwaySheet = false
        sessionEndedWhileAsking = false
        secondsRemaining = durationSeconds
    }

    private func tick() {
        guard isRunning, let endDate else { return }
        let remaining = Int(ceil(endDate.timeIntervalSinceNow))
        if remaining <= 0 {
            complete()
        } else {
            secondsRemaining = remaining
        }
    }

    /// Measures the time away, then asks the user which app they used.
    private func recordAwayTime() {
        guard let left = leftAt else { return }
        leftAt = nil
        let until = min(Date(), endDate ?? Date())
        let seconds = max(0, Int(until.timeIntervalSince(left).rounded()))
        if seconds > 0 {
            pendingAwaySeconds += seconds
            showAwaySheet = true
        }
    }

    /// Called when the user picks an app (nil = unknown, counts as distraction).
    private func resolveAway(_ app: TrackedApp?) {
        let seconds = pendingAwaySeconds
        guard seconds > 0 else { return }
        pendingAwaySeconds = 0
        showAwaySheet = false

        dataManager.recordAway(seconds: seconds, in: app)
        if app?.isProductive == true {
            productiveAwaySeconds += seconds
        } else {
            awaySeconds += seconds
        }

        if sessionEndedWhileAsking {
            sessionEndedWhileAsking = false
            finishSession()
        }
    }

    private func complete() {
        recordAwayTime()

        isRunning = false
        endDate = nil

        if pendingAwaySeconds > 0 {
            // Wait for the user's answer, then finish
            sessionEndedWhileAsking = true
        } else {
            finishSession()
        }
    }

    private func finishSession() {
        // Only distracting time is subtracted. Time in productive apps stays as focus.
        let focusedSeconds = max(durationSeconds - awaySeconds, 0)
        dataManager.addFocusSession(durationSeconds: focusedSeconds)

        summary = SessionSummary(
            seconds: focusedSeconds,
            interruptions: interruptions,
            awaySeconds: awaySeconds,
            productiveAwaySeconds: productiveAwaySeconds
        )

        interruptions = 0
        awaySeconds = 0
        productiveAwaySeconds = 0
        secondsRemaining = durationSeconds
    }

    private var timeString: String {
        let hours = secondsRemaining / 3600
        let minutes = (secondsRemaining % 3600) / 60
        let seconds = secondsRemaining % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - "Which app did you use?" sheet

private struct AwaySheet: View {
    @EnvironmentObject var dataManager: DataManager
    let seconds: Int
    let onPick: (TrackedApp?) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(dataManager.trackedApps) { app in
                        Button {
                            onPick(app)
                        } label: {
                            HStack {
                                Text(app.name).foregroundStyle(.primary)
                                Spacer()
                                Text(app.isProductive ? "Productive" : "Distracting")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .foregroundStyle(app.isProductive ? Color.brandGreenText : Color.orange)
                                    .background((app.isProductive ? Color.brandGreen : Color.orange).opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                } header: {
                    Text("You were away for \(seconds.secondsAsDuration). Which app did you use?")
                        .textCase(nil)
                }

                Section {
                    Button("Something else (counts as distraction)") {
                        onPick(nil)
                    }
                    .foregroundStyle(.orange)
                }
            }
            .navigationTitle("Welcome back")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Edit apps") {
                        AppListView()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FocusSessionView()
            .environmentObject(DataManager())
    }
}
