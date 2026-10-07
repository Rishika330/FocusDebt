import SwiftUI

struct ModeSelectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Choose your mode")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Select how you want to explore Focus Debt.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 6)

            Spacer()
                .frame(height: 35)

            NavigationLink {
                DashboardView()
            } label: {
                ModeCard(
                    icon: "chart.bar.fill",
                    title: "Demo Mode",
                    description: "Explore Focus Debt using realistic student data.",
                    color: Color.brandBlue
                )
            }
            .buttonStyle(AccentPressStyle())

            Spacer()
                .frame(height: 18)

            NavigationLink {
                DashboardView()
            } label: {
                ModeCard(
                    icon: "iphone",
                    title: "Live Mode",
                    description: "Use the data available directly within the app.",
                    color: .green
                )
            }
            .buttonStyle(AccentPressStyle())

            Spacer()

            Text("Demo Mode is recommended for exploring all features.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .navigationTitle("Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ModeCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 18) {

            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundStyle(.white)
                .frame(width: 55, height: 55)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        ModeSelectionView()
    }
}

