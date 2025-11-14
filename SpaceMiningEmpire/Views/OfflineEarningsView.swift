import SwiftUI

/// Modal view that displays credits earned while the player was away
struct OfflineEarningsView: View {
    // MARK: - Properties

    let earnings: Double
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Welcome back icon
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)

            // Title
            Text("Welcome Back, Captain!")
                .font(.title.bold())
                .foregroundColor(.white)

            // Earnings message
            VStack(spacing: 8) {
                Text("You earned")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(earnings.formattedCredits)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)

                Text("Credits while you were away!")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Dismiss button
            Button(action: onDismiss) {
                Text("Continue Mining")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.95))
    }
}

// MARK: - Preview

#Preview {
    OfflineEarningsView(earnings: 12345.67) {
        print("Dismissed")
    }
}
