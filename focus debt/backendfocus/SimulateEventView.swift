import SwiftUI

struct SimulateEventView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var lastAdded: String?

    private struct Preset: Identifiable {
        let id = UUID()
        let name: String
        let minutes: Int
        let category: AppCategory
    }

    private let presets = [
        Preset(name: "YouTube", minutes: 20, category: .entertainment),
        Preset(name: "Instagram", minutes: 15, category: .social),
        Preset(name: "WhatsApp", minutes: 10, category: .communication),
        Preset(name: "Netflix", minutes: 30, category: .entertainment)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Simulation only. This does not monitor your phone.", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }

                Section("Simulate usage") {
                    ForEach(presets) { preset in
                        Button {
                            dataManager.simulateUsageEvent(
                                appName: preset.name,
                                minutes: preset.minutes,
                                category: preset.category
                            )
                            lastAdded = "+\(preset.minutes) min \(preset.name) (simulated)"
                        } label: {
                            HStack {
                                Text("+\(preset.minutes) min \(preset.name)")
                                Spacer()
                                Image(systemName: "plus.circle")
                            }
                        }
                    }
                }

                if let lastAdded {
                    Section {
                        Text("Added \(lastAdded)")
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Simulate Usage")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
