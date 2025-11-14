import SwiftUI

/// View component that displays a single click upgrade row with icon, stats, and upgrade button
struct ClickUpgradeRowView: View {
    // MARK: - Properties

    let upgrade: ClickUpgrade
    @ObservedObject var viewModel: GameViewModel

    // MARK: - Body

    var body: some View {
        HStack {
            // Left: Icon + Info
            HStack(spacing: 12) {
                // Upgrade Icon
                Image(systemName: upgrade.iconName)
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .frame(width: 40, height: 40)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)

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
    }

    // MARK: - Subviews

    /// Button to unlock or upgrade the click upgrade
    private var levelUpButton: some View {
        Button(action: {
            viewModel.levelUpClickUpgrade(upgradeID: upgrade.id)
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
                viewModel.credits >= upgrade.nextLevelCost
                    ? Color.orange
                    : Color.gray
            )
            .cornerRadius(8)
        }
        .disabled(viewModel.credits < upgrade.nextLevelCost)
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
