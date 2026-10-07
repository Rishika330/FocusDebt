import Foundation

extension Int {
    /// Minutes -> "1h 28m", 45 -> "45m", 120 -> "2h"
    var asHoursMinutes: String {
        let h = self / 60
        let m = self % 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }

    /// Seconds -> "45s", "5m 12s", "5m", "1h 5m"
    var secondsAsDuration: String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = self % 60
        if h > 0 { return m == 0 ? "\(h)h" : "\(h)h \(m)m" }
        if m > 0 { return s == 0 ? "\(m)m" : "\(m)m \(s)s" }
        return "\(s)s"
    }
}
