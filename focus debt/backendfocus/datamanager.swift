import Foundation
import Combine

enum AppMode: String {
    case live
    case demo

    var namespace: String {
        switch self {
        case .live: return "focusDebt"
        case .demo: return "focusDebt.demo"
        }
    }
}

final class DataManager: ObservableObject {
    @Published private(set) var student: Student
    @Published private(set) var activities: [DailyActivity]
    @Published private(set) var appUsage: [AppUsage]
    @Published private(set) var mode: AppMode
    @Published private(set) var currentEmail: String = ""
    @Published private(set) var trackedApps: [TrackedApp] = []
    @Published var isLoggedIn = false

    private var localService: LocalDataService
    private let calendar = Calendar.current
    private let modeKey = "appMode"
    private let savedEmailKey = "savedUserEmail"

    init() {
        let launchedKey = "hasLaunchedBefore_v3"
        if !UserDefaults.standard.bool(forKey: launchedKey) {
            for key in [
                "focusDebt.student",
                "focusDebt.activities", "focusDebt.appUsage",
                "focusDebt.demo.activities", "focusDebt.demo.appUsage"
            ] {
                UserDefaults.standard.removeObject(forKey: key)
            }
            UserDefaults.standard.removeObject(forKey: modeKey)
            UserDefaults.standard.set(true, forKey: launchedKey)
        }

        // Clear any lingering saved email so the login/verification page shows up fresh
        UserDefaults.standard.removeObject(forKey: savedEmailKey)

        let savedModeString = UserDefaults.standard.string(forKey: modeKey) ?? ""
        let savedMode = AppMode(rawValue: savedModeString) ?? .live

        self.mode = savedMode
        self.localService = LocalDataService(namespace: savedMode.namespace, userKey: "")
        self.student = Student(name: "", dailyStudyGoalMinutes: 0)
        self.activities = []
        self.appUsage = []
        self.isLoggedIn = false
    }

    // MARK: - Authentication & Strict Email Verification
    @discardableResult
    func signIn(name: String, email: String, goalMinutes: Int) -> Bool {
        let cleanEmail = Student.normalize(email)
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard Student.isValid(email: cleanEmail), !cleanName.isEmpty else {
            return false
        }

        currentEmail = cleanEmail
        localService = LocalDataService(namespace: mode.namespace, userKey: cleanEmail)

        let existing = localService.loadStudent()
        let profile = Student(
            id: existing?.id ?? UUID(),
            name: cleanName,
            email: cleanEmail,
            dailyStudyGoalMinutes: goalMinutes
        )
        student = profile
        localService.saveStudent(profile)

        activities = localService.loadActivities() ?? []
        appUsage = localService.loadAppUsage() ?? []

        if mode == .demo && activities.isEmpty {
            loadDemoScenario()
        }

        if todayIndex != nil {
            updateToday()
        }

        UserDefaults.standard.set(cleanEmail, forKey: savedEmailKey)
        isLoggedIn = true
        return true
    }

    func logOut() {
        UserDefaults.standard.removeObject(forKey: savedEmailKey)
        isLoggedIn = false
        currentEmail = ""
        student = Student(name: "", dailyStudyGoalMinutes: 0)
        activities = []
        appUsage = []
        trackedApps = []
        localService = LocalDataService(namespace: mode.namespace, userKey: "")
    }

    // MARK: - Mode Management
    func setMode(_ newMode: AppMode) {
        guard newMode != mode else { return }

        mode = newMode
        UserDefaults.standard.set(newMode.rawValue, forKey: modeKey)

        localService = LocalDataService(namespace: newMode.namespace, userKey: currentEmail)
        activities = localService.loadActivities() ?? []
        appUsage = localService.loadAppUsage() ?? []
        trackedApps = localService.loadTrackedApps() ?? TrackedApp.defaults

        if newMode == .demo && isLoggedIn && activities.isEmpty {
            loadDemoScenario()
        }
    }

    func loadDemoScenario() {
        guard mode == .demo else { return }
        let scenario = DemoData.scenario(goalMinutes: student.dailyStudyGoalMinutes)
        activities = scenario.activities
        appUsage = scenario.usage
        localService.saveActivities(activities)
        localService.saveAppUsage(appUsage)
    }

    func resetCurrentModeData() {
        localService.clearModeData()
        activities = []
        appUsage = []
    }

    // MARK: - Today Helpers
    private var todayIndex: Int? {
        activities.lastIndex { calendar.isDateInToday($0.date) }
    }

    var todayActivity: DailyActivity {
        if let i = todayIndex { return activities[i] }
        return DailyActivity(
            date: Date(),
            focusMinutes: 0,
            distractionMinutes: 0,
            studyGoalMinutes: student.dailyStudyGoalMinutes,
            interruptions: 0
        )
    }

    var todayAppUsage: [AppUsage] {
        appUsage.filter { calendar.isDateInToday($0.date) }
    }

    private func updateToday(
        focus: Int = 0,
        focusSeconds: Int = 0,
        distraction: Int = 0,
        interruptions: Int = 0,
        awaySeconds: Int = 0,
        interruptionLogs: [Int] = []
    ) {
        if let i = todayIndex {
            let c = activities[i]
            let carry = c.focusSeconds + focusSeconds
            let updatedLogs = c.interruptionLogs + interruptionLogs
            
            let newFocusMinutes = c.focusMinutes + focus + (carry / 60)
            let newDistractionMinutes = c.distractionMinutes + distraction
            let newInterruptions = c.interruptions + interruptions
            let newAwaySeconds = c.awaySeconds + awaySeconds
            let newFocusSeconds = carry % 60
            
            activities[i] = DailyActivity(
                id: c.id,
                date: c.date,
                focusMinutes: newFocusMinutes,
                distractionMinutes: newDistractionMinutes,
                studyGoalMinutes: student.dailyStudyGoalMinutes,
                interruptions: newInterruptions,
                awaySeconds: newAwaySeconds,
                focusSeconds: newFocusSeconds,
                interruptionLogs: updatedLogs
            )
        } else {
            let initialFocusMinutes = focus + (focusSeconds / 60)
            let initialFocusSeconds = focusSeconds % 60
            
            activities.append(
                DailyActivity(
                    date: Date(),
                    focusMinutes: initialFocusMinutes,
                    distractionMinutes: distraction,
                    studyGoalMinutes: student.dailyStudyGoalMinutes,
                    interruptions: interruptions,
                    awaySeconds: awaySeconds,
                    focusSeconds: initialFocusSeconds,
                    interruptionLogs: interruptionLogs
                )
            )
        }
        localService.saveActivities(activities)
    }

    // MARK: - Computed Analytics
    var todayFocusDebt: Int {
        FocusDebtEngine.calculateDailyDebt(todayActivity)
    }

    var todayFocusScore: Int {
        FocusScoreEngine.calculateScore(todayActivity)
    }

    var todayDistractionMinutes: Int {
        todayActivity.distractionMinutes
    }

    var todayDistractionSeconds: Int {
        todayActivity.totalDistractionSeconds
    }

    var weeklyFocusDebt: Int {
        FocusDebtEngine.calculateWeeklyDebt(activities)
    }

    var todayInsight: String {
        BehaviorAnalyzer.generateInsight(
            activity: todayActivity,
            appUsage: todayAppUsage
        )
    }

    var weeklyInsight: String {
        BehaviorAnalyzer.generateWeeklyInsight(activities: activities)
    }

    // MARK: - Inputs & Tracking
    func addFocusSession(durationSeconds: Int) {
        guard durationSeconds > 0 else { return }
        updateToday(focusSeconds: durationSeconds)
    }

    func addFocusSession(durationMinutes: Int) {
        addFocusSession(durationSeconds: durationMinutes * 60)
    }

    func addActivity(
        focusMinutes: Int,
        distractionMinutes: Int,
        interruptions: Int
    ) {
        guard focusMinutes >= 0, distractionMinutes >= 0, interruptions >= 0 else { return }
        updateToday(
            focus: focusMinutes,
            distraction: distractionMinutes,
            interruptions: interruptions
        )
    }

    func addAppUsage(
        appName: String,
        minutes: Int,
        category: AppCategory,
        source: UsageSource = .manual
    ) {
        let name = appName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, minutes > 0 else { return }

        appUsage.append(
            AppUsage(
                appName: name,
                minutesUsed: minutes,
                category: category,
                source: source
            )
        )
        localService.saveAppUsage(appUsage)

        if category != .study {
            updateToday(distraction: minutes)
        }
    }

    func simulateUsageEvent(
        appName: String,
        minutes: Int,
        category: AppCategory
    ) {
        addAppUsage(
            appName: appName,
            minutes: minutes,
            category: category,
            source: .simulated
        )
    }

    func logInterruption() {
        updateToday(interruptions: 1)
    }

    func addAwayTime(seconds: Int, logs: [Int]) {
        guard seconds > 0 else { return }
        updateToday(awaySeconds: seconds, interruptionLogs: logs)
    }

    func addAwayTime(seconds: Int, interruptionLogs: [Int]) {
        guard seconds > 0 else { return }
        updateToday(awaySeconds: seconds, interruptionLogs: interruptionLogs)
    }

    func addAwayTime(seconds: Int) {
        guard seconds > 0 else { return }
        updateToday(awaySeconds: seconds, interruptionLogs: [])
    }

    // MARK: - App list (productive / distracting)

    func addTrackedApp(name: String, isProductive: Bool) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty,
              !trackedApps.contains(where: { $0.name.lowercased() == clean.lowercased() })
        else { return }
        trackedApps.append(TrackedApp(name: clean, isProductive: isProductive))
        localService.saveTrackedApps(trackedApps)
    }

    func setProductive(_ app: TrackedApp, _ value: Bool) {
        guard let i = trackedApps.firstIndex(where: { $0.id == app.id }) else { return }
        trackedApps[i].isProductive = value
        localService.saveTrackedApps(trackedApps)
    }

    func removeTrackedApp(_ app: TrackedApp) {
        trackedApps.removeAll { $0.id == app.id }
        localService.saveTrackedApps(trackedApps)
    }

    /// Time spent away from the app, in the app the user picked.
    /// Productive app: not a distraction, so the time stays as focus.
    /// Distracting app (or no app picked): counts as distraction.
    func recordAway(seconds: Int, in app: TrackedApp?) {
        guard seconds > 0 else { return }
        guard let app else {
            addAwayTime(seconds: seconds)
            return
        }
        let minutes = max(1, Int((Double(seconds) / 60).rounded()))
        appUsage.append(
            AppUsage(
                appName: app.name,
                minutesUsed: minutes,
                category: app.isProductive ? .study : .entertainment,
                source: .manual
            )
        )
        localService.saveAppUsage(appUsage)
        if !app.isProductive {
            addAwayTime(seconds: seconds)
        }
    }
    // MARK: - Student Profile & Reset
    func updateStudent(name: String, goalMinutes: Int) {
        let updated = Student(
            id: student.id,
            name: name,
            email: currentEmail,
            dailyStudyGoalMinutes: goalMinutes
        )
        student = updated
        localService.saveStudent(updated)

        if todayIndex != nil {
            updateToday()
        }
    }

    func resetData() {
        for m in [AppMode.live, AppMode.demo] {
            LocalDataService(namespace: m.namespace, userKey: currentEmail).clearAllData()
        }
        UserDefaults.standard.removeObject(forKey: modeKey)
        mode = .live
        logOut()
    }
}
