import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var name = ""
    @State private var goalText = ""
    @State private var showResetMode = false
    @State private var showResetAll = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var goal: Int { Int(goalText) ?? 0 }
    private var canSaveProfile: Bool { !trimmedName.isEmpty && goal > 0 }

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $name)
                TextField("Daily study goal (minutes)", text: $goalText)
                    .keyboardType(.numberPad)
                Button("Save Profile") {
                    dataManager.updateStudent(name: trimmedName, goalMinutes: goal)
                }
                .disabled(!canSaveProfile)
            }

            Section {
                Picker("Mode", selection: Binding(
                    get: { dataManager.mode },
                    set: { dataManager.setMode($0) }
                )) {
                    Text("Live").tag(AppMode.live)
                    Text("Demo").tag(AppMode.demo)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Mode")
            } footer: {
                Text("Live uses your real sessions and manual entries. Demo shows a sample week so you can present the app. The two keep separate data.")
            }

            if dataManager.mode == .demo {
                Section {
                    Button("Reload Sample Scenario") {
                        dataManager.loadDemoScenario()
                    }
                } header: {
                    Text("Demo Tools")
                } footer: {
                    Text("Simulation only. Sample data is not collected from your device.")
                }
            }

            Section("Data") {
                Button("Reset \(dataManager.mode == .live ? "Live" : "Demo") Data", role: .destructive) {
                    showResetMode = true
                }
                Button("Log Out") {
                    dataManager.logOut()
                }
                Button("Reset Everything", role: .destructive) {
                    showResetAll = true
                }
            }

            Section("About") {
                Text("Focus Debt does not read system-wide iPhone usage. It processes focus sessions recorded in this app and app usage that is entered manually or simulated.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            name = dataManager.student.name
            let saved = dataManager.student.dailyStudyGoalMinutes
            goalText = saved > 0 ? "\(saved)" : ""
        }
        .confirmationDialog(
            "Clear this mode's activity and app usage?",
            isPresented: $showResetMode,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                dataManager.resetCurrentModeData()
            }
        }
        .confirmationDialog(
            "Erase your profile and all data in both modes?",
            isPresented: $showResetAll,
            titleVisibility: .visible
        ) {
            Button("Erase Everything", role: .destructive) {
                dataManager.resetData()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(DataManager())
    }
}
