import SwiftUI

/// Modal view displaying all achievements with progress and unlock status
struct AchievementsView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: GameViewModel
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Achievement list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.achievementManager.achievements) { achievement in
                        AchievementRowView(
                            achievement: achievement,
                            currentValue: getCurrentValue(for: achievement),
                            viewModel: viewModel
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color.black)
    }

    // MARK: - Subviews

    /// Header with title, close button, and statistics
    private var headerView: some View {
        VStack(spacing: 16) {
            // Title and close button
            HStack {
                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    Text("Achievements")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            // Achievement stats
            HStack(spacing: 24) {
                // Unlocked count
                VStack(spacing: 4) {
                    Text("\(viewModel.achievementManager.unlockedCount)/\(viewModel.achievementManager.totalCount)")
                        .font(.title2.bold())
                        .foregroundColor(.cyan)
                    Text("Unlocked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))

                // Total multiplier bonus
                VStack(spacing: 4) {
                    Text("\(viewModel.achievementMultiplier, specifier: "%.2f")x")
                        .font(.title2.bold())
                        .foregroundColor(.yellow)
                    Text("Multiplier")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))

                // Bonus percentage
                VStack(spacing: 4) {
                    Text("+\((viewModel.achievementMultiplier - 1.0) * 100, specifier: "%.0f")%")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Bonus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - Helper Functions

    /// Gets the current value for an achievement based on its requirement type
    private func getCurrentValue(for achievement: Achievement) -> Double {
        switch achievement.requirementType {
        case .credits:
            return viewModel.totalCreditsEarned
        case .generators:
            return Double(viewModel.generators.filter { $0.isUnlocked }.count)
        case .generatorLevel:
            return Double(viewModel.generators.map { $0.level }.max() ?? 0)
        case .taps:
            return Double(viewModel.totalTaps)
        case .prestigeCount:
            return Double(viewModel.prestigeManager.lifetimePrestigeCount)
        case .stellarShards:
            return Double(viewModel.stellarShards)
        case .clickUpgrades:
            return Double(viewModel.clickUpgrades.filter { $0.isUnlocked }.count)
        case .creditsPerSecond:
            return viewModel.totalCreditsPerSecond
        }
    }
}

// MARK: - Achievement Row View

/// Individual row for displaying a single achievement
struct AchievementRowView: View {
    let achievement: Achievement
    let currentValue: Double
    let viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ?
                          LinearGradient(
                            colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) :
                          LinearGradient(
                            colors: [.gray.opacity(0.2), .gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }

            // Achievement info
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)

                // Description
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Progress bar (only show if not unlocked)
                if !achievement.isUnlocked {
                    VStack(alignment: .leading, spacing: 2) {
                        // Progress text
                        Text(progressText)
                            .font(.caption2)
                            .foregroundColor(.cyan)

                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                    .cornerRadius(2)

                                // Progress
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * progress, height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                }

                // Reward info
                HStack(spacing: 4) {
                    Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "gift.fill")
                        .font(.caption)
                        .foregroundColor(achievement.isUnlocked ? .green : .purple)
                    Text(achievement.isUnlocked ? "Unlocked!" : "+\(Int(achievement.rewardMultiplier * 100))% multiplier")
                        .font(.caption2)
                        .foregroundColor(achievement.isUnlocked ? .green : .purple)
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isUnlocked ?
                      Color.white.opacity(0.1) :
                      Color.white.opacity(0.03)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ?
                        Color.yellow.opacity(0.3) :
                        Color.gray.opacity(0.2),
                        lineWidth: achievement.isUnlocked ? 1 : 0.5
                )
        )
    }

    // MARK: - Computed Properties

    /// Progress towards this achievement (0.0 to 1.0)
    private var progress: Double {
        achievement.progress(currentValue: currentValue)
    }

    /// Text showing current progress
    private var progressText: String {
        let formatted = formatValue(currentValue)
        let target = formatValue(achievement.targetValue)
        return "\(formatted) / \(target)"
    }

    /// Formats a value based on the achievement type
    private func formatValue(_ value: Double) -> String {
        switch achievement.requirementType {
        case .credits:
            return value.formattedCredits
        case .creditsPerSecond:
            return value.formattedCredits
        case .generators, .generatorLevel, .taps, .prestigeCount, .stellarShards, .clickUpgrades:
            return "\(Int(value))"
        }
    }
}

// MARK: - Preview

#Preview {
    AchievementsView(
        viewModel: GameViewModel(),
        onDismiss: { print("Dismissed") }
    )
}
