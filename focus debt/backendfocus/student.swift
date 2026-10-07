import Foundation

struct Student: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String            // normalized: trimmed + lowercased. This is the unique user key.
    var dailyStudyGoalMinutes: Int

    init(
        id: UUID = UUID(),
        name: String,
        email: String = "",
        dailyStudyGoalMinutes: Int
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.dailyStudyGoalMinutes = dailyStudyGoalMinutes
    }

    // Older saved profiles have no email, so decode it as optional.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        dailyStudyGoalMinutes = try c.decode(Int.self, forKey: .dailyStudyGoalMinutes)
    }

    // MARK: - Email helpers

    static func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Light check only (no real authentication).
    static func isValid(email: String) -> Bool {
        let e = normalize(email)
        guard let at = e.firstIndex(of: "@"), at != e.startIndex else { return false }
        let domain = e[e.index(after: at)...]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }
}
