import SwiftUI

struct AddActivityView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    @State private var focusText = ""
    @State private var distractionText = ""
    @State private var interruptionText = ""

    private var focus: Int { Int(focusText) ?? 0 }
    private var distraction: Int { Int(distractionText) ?? 0 }
    private var interruptions: Int { Int(interruptionText) ?? 0 }
    private var isValid: Bool { focus > 0 || distraction > 0 || interruptions > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Focus minutes", text: $focusText)
                        .keyboardType(.numberPad)
                    TextField("Other distraction minutes", text: $distractionText)
                        .keyboardType(.numberPad)
                    TextField("Interruptions", text: $interruptionText)
                        .keyboardType(.numberPad)
                } footer: {
                    Text("Added to today's totals. App usage you log separately already counts as distraction, so only enter distraction here if it isn't in your app usage.")
                }
            }
            .navigationTitle("Today's Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataManager.addActivity(
                            focusMinutes: focus,
                            distractionMinutes: distraction,
                            interruptions: interruptions
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
