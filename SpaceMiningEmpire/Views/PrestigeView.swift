import SwiftUI

/// Modal view for the prestige system that displays Stellar Shards and allows ascending
struct PrestigeView: View {
    // MARK: - Properties

    let currentShards: Int
    let potentialShards: Int
    let currentMultiplier: Double
    let newMultiplier: Double
    let onPrestige: () -> Void
    let onDismiss: () -> Void

    @State private var showingConfirmation = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Prestige icon with dramatic effect
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.6), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Title
            Text("Ascend to Greatness")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            // Stellar Shards info
            VStack(spacing: 16) {
                // Current shards
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .foregroundColor(.cyan)
                    Text("Current Stellar Shards:")
                        .foregroundColor(.secondary)
                    Text("\(currentShards)")
                        .font(.headline)
                        .foregroundColor(.cyan)
                }

                // Potential new shards
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .foregroundColor(.yellow)
                    Text("Gain on Prestige:")
                        .foregroundColor(.secondary)
                    Text("+\(potentialShards)")
                        .font(.headline.bold())
                        .foregroundColor(.yellow)
                }

                // Total after prestige
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .foregroundColor(.purple)
                    Text("Total After:")
                        .foregroundColor(.secondary)
                    Text("\(currentShards + potentialShards)")
                        .font(.headline.bold())
                        .foregroundColor(.purple)
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                // Multiplier info
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("Current Multiplier:")
                            .foregroundColor(.secondary)
                        Text("\(currentMultiplier, specifier: "%.1f")x")
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    if potentialShards > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(.yellow)
                            Text("New Multiplier:")
                                .foregroundColor(.secondary)
                            Text("\(newMultiplier, specifier: "%.1f")x")
                                .font(.headline.bold())
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)

            // Warning message
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("All generators and credits will be reset!")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                // Ascend button
                Button(action: {
                    if potentialShards > 0 {
                        showingConfirmation = true
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("Ascend to the Stars")
                            .font(.headline.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        potentialShards > 0 ?
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [.gray, .gray],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: potentialShards > 0 ? .purple.opacity(0.5) : .clear, radius: 10)
                }
                .disabled(potentialShards == 0)

                // Cancel button
                Button(action: onDismiss) {
                    Text("Maybe Later")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black, Color.purple.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("Confirm Ascension", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Ascend", role: .destructive) {
                onPrestige()
            }
        } message: {
            Text("Are you sure you want to prestige? All your generators and credits will be reset, but you'll gain \(potentialShards) Stellar Shard\(potentialShards == 1 ? "" : "s") for a permanent \(newMultiplier, specifier: "%.1f")x production multiplier!")
        }
    }
}

// MARK: - Preview

#Preview {
    PrestigeView(
        currentShards: 5,
        potentialShards: 3,
        currentMultiplier: 1.5,
        newMultiplier: 1.8,
        onPrestige: { print("Prestiged!") },
        onDismiss: { print("Dismissed") }
    )
}
