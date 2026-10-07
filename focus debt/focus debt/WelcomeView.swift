import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var name = ""
    @State private var email = ""
    @State private var goalText = ""

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var goal: Int { Int(goalText) ?? 0 }
    private var emailIsValid: Bool { Student.isValid(email: email) }
    private var isValid: Bool { !trimmedName.isEmpty && emailIsValid && goal > 0 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Log in with your email to keep your focus history. Then set how much you want to focus today.")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("e.g. Sandesh", text: $name)
                        .textInputAutocapitalization(.words)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("e.g. sandesh@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    if !email.isEmpty && !emailIsValid {
                        Text("Enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's study goal (minutes)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("e.g. 300", text: $goalText)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    if goal > 0 {
                        Text("That's \(goal.asHoursMinutes) per day.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    dataManager.signIn(
                        name: trimmedName,
                        email: email,
                        goalMinutes: goal
                    )
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(isValid ? Color.brandBlue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!isValid)

                Text("Your history is stored on this device and tied to your email. There is no password.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .navigationTitle("Log in")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
            .environmentObject(DataManager())
    }
}
