import SwiftUI

/// A card view for displaying individual statistics
struct StatCardView: View {
    let iconName: String
    let label: String
    let value: String
    let gradientColors: [Color]

    init(iconName: String, label: String, value: String, gradientColors: [Color] = [.blue, .purple]) {
        self.iconName = iconName
        self.label = label
        self.value = value
        self.gradientColors = gradientColors
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Label
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)

            // Value
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(0.15) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(0.3) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()

        VStack(spacing: 16) {
            StatCardView(
                iconName: "chart.line.uptrend.xyaxis",
                label: "Lifetime Credits",
                value: "1.23M",
                gradientColors: [.blue, .cyan]
            )

            StatCardView(
                iconName: "hand.tap.fill",
                label: "Total Taps",
                value: "12,345",
                gradientColors: [.purple, .pink]
            )

            StatCardView(
                iconName: "clock.fill",
                label: "Time Played",
                value: "12h 34m",
                gradientColors: [.orange, .red]
            )
        }
        .padding()
    }
}
