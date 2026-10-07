import SwiftUI

struct AppListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newName = ""
    @State private var newIsProductive = false

    var body: some View {
        List {
            Section {
                ForEach(dataManager.trackedApps) { app in
                    Toggle(isOn: Binding(
                        get: { app.isProductive },
                        set: { dataManager.setProductive(app, $0) }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.name)
                            Text(app.isProductive
                                 ? "Productive: time stays as focus"
                                 : "Distracting: counts as distraction")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(Color.brandGreen)
                }
                .onDelete { offsets in
                    let apps = offsets.map { dataManager.trackedApps[$0] }
                    apps.forEach { dataManager.removeTrackedApp($0) }
                }
            } header: {
                Text("Switch on the apps that help you study")
                    .textCase(nil)
            }

            Section("Add an app") {
                TextField("App name, e.g. Notion", text: $newName)
                Toggle("Productive", isOn: $newIsProductive)
                    .tint(Color.brandGreen)
                Button("Add") {
                    dataManager.addTrackedApp(name: newName, isProductive: newIsProductive)
                    newName = ""
                    newIsProductive = false
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("My Apps")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppListView()
            .environmentObject(DataManager())
    }
}
