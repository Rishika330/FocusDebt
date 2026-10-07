import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.brandBlue)

                Spacer()
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    MetricCard(
        title: "Focus Debt",
        value: "1h 28m",
        subtitle: "Today",
        icon: "clock.badge.exclamationmark"
    )
    .padding()
}

