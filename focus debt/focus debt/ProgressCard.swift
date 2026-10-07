import SwiftUI

struct ProgressCard: View {
    let title: String
    let current: String
    let target: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(current) / \(target)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(Color.brandGreen)
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ProgressCard(
        title: "Today's Focus",
        current: "3h 32m",
        target: "5h",
        progress: 0.70
    )
    .padding()
}

