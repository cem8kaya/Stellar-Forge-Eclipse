import SwiftUI

/// View component that displays a single generator row with icon, stats, and upgrade button
struct GeneratorRowView: View {
    // MARK: - Properties

    let generator: Generator
    @ObservedObject var viewModel: GameViewModel

    // MARK: - Body

    var body: some View {
        HStack {
            // Left: Icon + Info
            HStack(spacing: 12) {
                // Generator Icon
                Image(systemName: generator.iconName)
                    .font(.title2)
                    .foregroundColor(.cyan)
                    .frame(width: 40, height: 40)
                    .background(Color.cyan.opacity(0.2))
                    .cornerRadius(8)

                // Generator Info
                VStack(alignment: .leading, spacing: 4) {
                    // Generator Name
                    Text(generator.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    // Level and Production Stats
                    HStack(spacing: 4) {
                        Text("Lv.\(generator.level)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if generator.level > 0 {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("\(generator.currentProductionPerSecond.formattedCredits)/s")
                                .font(.caption)
                                .foregroundColor(.green)
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

    /// Button to unlock or upgrade the generator
    private var levelUpButton: some View {
        Button(action: {
            viewModel.levelUp(generatorID: generator.id)
        }) {
            VStack(spacing: 2) {
                Text(generator.level == 0 ? "UNLOCK" : "UPGRADE")
                    .font(.caption.bold())
                Text(generator.nextLevelCost.formattedCredits)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                viewModel.credits >= generator.nextLevelCost
                    ? Color.blue
                    : Color.gray
            )
            .cornerRadius(8)
        }
        .disabled(viewModel.credits < generator.nextLevelCost)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = GameViewModel()
    return GeneratorRowView(
        generator: Generator(
            name: "Mining Probe",
            level: 1,
            baseCost: 10,
            baseProduction: 1,
            iconName: "antenna.radiowaves.left.and.right"
        ),
        viewModel: viewModel
    )
    .padding()
    .background(Color.black)
}
