import Foundation

/// Stores data per user (email) and per mode (live / demo).
/// Keys look like:
///   focusDebt.student.sandesh@gmail.com
///   focusDebt.sandesh@gmail.com.activities        (live)
///   focusDebt.demo.sandesh@gmail.com.activities   (demo)
final class LocalDataService {

    private let studentKey: String
    private let activityKey: String
    private let usageKey: String
    private let appListKey: String

    init(namespace: String = "focusDebt", userKey: String = "") {
        let user = userKey.isEmpty ? "guest" : userKey
        studentKey = "focusDebt.student.\(user)"       // profile shared by both modes
        activityKey = "\(namespace).\(user).activities"
        usageKey = "\(namespace).\(user).appUsage"
        appListKey = "focusDebt.apps.\(user)"       // app list is shared by both modes
    }

    func saveStudent(_ student: Student) {
        save(student, forKey: studentKey)
    }

    func loadStudent() -> Student? {
        load(Student.self, forKey: studentKey)
    }

    func saveActivities(_ activities: [DailyActivity]) {
        save(activities, forKey: activityKey)
    }

    func loadActivities() -> [DailyActivity]? {
        load([DailyActivity].self, forKey: activityKey)
    }

    func saveAppUsage(_ usage: [AppUsage]) {
        save(usage, forKey: usageKey)
    }

    func loadAppUsage() -> [AppUsage]? {
        load([AppUsage].self, forKey: usageKey)
    }

    func saveTrackedApps(_ apps: [TrackedApp]) {
        save(apps, forKey: appListKey)
    }

    func loadTrackedApps() -> [TrackedApp]? {
        load([TrackedApp].self, forKey: appListKey)
    }
    /// Clears only this user's activities and app usage for this mode (keeps the profile).
    func clearModeData() {
        UserDefaults.standard.removeObject(forKey: activityKey)
        UserDefaults.standard.removeObject(forKey: usageKey)
    }

    /// Clears this user's data for this mode and their profile.
    func clearAllData() {
        clearModeData()
        UserDefaults.standard.removeObject(forKey: studentKey)
        UserDefaults.standard.removeObject(forKey: appListKey)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save \(key): \(error)")
        }
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to load \(key): \(error)")
            return nil
        }
    }
}
