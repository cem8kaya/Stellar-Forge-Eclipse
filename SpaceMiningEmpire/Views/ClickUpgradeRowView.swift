import SwiftUI

/// View component that displays a single click upgrade row with icon, stats, and upgrade button
struct ClickUpgradeRowView: View {
    // MARK: - Properties

    let upgrade: ClickUpgrade
    @ObservedObject var viewModel: GameViewModel

    @State private var isPulsing = false
    @State private var celebrationTriggered = false
    @State private var iconScale: CGFloat = 1.0

    private var isAffordable: Bool {
        viewModel.credits >= upgrade.nextLevelCost
    }

    // MARK: - Body

    var body: some View {
        HStack {
            // Left: Icon + Info
            HStack(spacing: 12) {
                // Upgrade Icon with animations
                ZStack {
                    // Background glow for active upgrades
                    if upgrade.level > 0 {
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .blur(radius: 8)
                            .scaleEffect(isPulsing ? 1.2 : 1.0)
                            .opacity(isPulsing ? 0.8 : 0.5)
                    }

                    Image(systemName: upgrade.iconName)
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .frame(width: 40, height: 40)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                        .scaleEffect(iconScale)
                }

                // Upgrade Info
                VStack(alignment: .leading, spacing: 4) {
                    // Upgrade Name
                    Text(upgrade.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    // Level and Multiplier Stats
                    HStack(spacing: 4) {
                        Text("Lv.\(upgrade.level)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if upgrade.level > 0 {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("+\(upgrade.currentMultiplier.formattedCredits) per tap")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }

            Spacer()

            // Right: Level Up Button
            levelUpButton
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .celebration(isTriggered: $celebrationTriggered, color: .yellow)
        .scaleEffect(celebrationTriggered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: celebrationTriggered)
        .onAppear {
            startAnimations()
        }
        .onChange(of: isAffordable) { oldValue, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }

    // MARK: - Subviews

    /// Button to unlock or upgrade the click upgrade
    private var levelUpButton: some View {
        Button(action: {
            viewModel.levelUpClickUpgrade(upgradeID: upgrade.id)
            triggerCelebration()
        }) {
            VStack(spacing: 2) {
                Text(upgrade.level == 0 ? "UNLOCK" : "UPGRADE")
                    .font(.caption.bold())
                Text(upgrade.nextLevelCost.formattedCredits)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isAffordable
                    ? LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [.gray, .gray],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            )
            .cornerRadius(8)
            .shadow(color: isAffordable ? .yellow.opacity(0.5) : .clear, radius: isPulsing ? 8 : 0)
        }
        .disabled(!isAffordable)
    }

    // MARK: - Helpers

    private func startAnimations() {
        // Pulse icon for active upgrades
        if upgrade.level > 0 {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                iconScale = 1.1
            }
        }

        // Start pulse animation if affordable
        if isAffordable {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    private func triggerCelebration() {
        celebrationTriggered = true
    }
}

// MARK: - Preview

#Preview {
    let viewModel = GameViewModel()
    return ClickUpgradeRowView(
        upgrade: ClickUpgrade(
            name: "Titanium Finger",
            level: 1,
            baseCost: 50,
            baseMultiplier: 1,
            iconName: "hand.tap.fill"
        ),
        viewModel: viewModel
    )
    .padding()
    .background(Color.black)
}
