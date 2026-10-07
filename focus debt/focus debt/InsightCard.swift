import SwiftUI

struct InsightCard: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.brandBlue)
                .frame(width: 40, height: 40)
                .background(Color.brandBlue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    InsightCard(
        title: "Today's Insight",
        message: "Your largest source of Focus Debt was distraction during your planned study period.",
        icon: "lightbulb.fill"
    )
    .padding()
}
