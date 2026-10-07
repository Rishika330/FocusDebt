import SwiftUI

struct AddAppUsageView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    @State private var appName = ""
    @State private var minutesText = ""
    @State private var category: AppCategory = .social

    private var minutes: Int { Int(minutesText) ?? 0 }
    private var isValid: Bool {
        !appName.trimmingCharacters(in: .whitespaces).isEmpty && minutes > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("App name (e.g. YouTube)", text: $appName)
                    TextField("Minutes used", text: $minutesText)
                        .keyboardType(.numberPad)
                    Picker("Category", selection: $category) {
                        ForEach(AppCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                } footer: {
                    Text("Entered manually. Focus Debt does not read other apps' usage automatically.")
                }
            }
            .navigationTitle("Add App Usage")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataManager.addAppUsage(
                            appName: appName,
                            minutes: minutes,
                            category: category
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    AddAppUsageView()
        .environmentObject(DataManager())
}
