import Foundation

/// Manages all achievements, checking unlock conditions and calculating bonuses
struct AchievementManager: Codable {
    // MARK: - Properties

    /// Array of all achievements in the game
    var achievements: [Achievement]

    /// Timestamp of when achievements were last notified (to avoid spam)
    var lastNotificationTime: Date = Date()

    // MARK: - Computed Properties

    /// Total multiplier bonus from all unlocked achievements
    /// Formula: 1 + sum of all reward multipliers
    var totalAchievementMultiplier: Double {
        1.0 + achievements
            .filter { $0.isUnlocked }
            .reduce(0.0) { $0 + $1.rewardMultiplier }
    }

    /// Number of unlocked achievements
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    /// Total number of achievements
    var totalCount: Int {
        achievements.count
    }

    // MARK: - Initialization

    init() {
        self.achievements = Self.createDefaultAchievements()
    }

    // MARK: - Achievement Checking

    /// Checks all achievements and unlocks any that meet their requirements
    /// - Parameters:
    ///   - credits: Current credits
    ///   - totalCreditsEarned: Total credits earned across all time
    ///   - generators: Array of all generators
    ///   - taps: Total taps performed
    ///   - prestigeCount: Number of times prestiged
    ///   - stellarShards: Total stellar shards earned
    ///   - clickUpgrades: Array of all click upgrades
    ///   - creditsPerSecond: Current production per second
    /// - Returns: Array of newly unlocked achievements (for notifications)
    mutating func checkAchievements(
        credits: Double,
        totalCreditsEarned: Double,
        generators: [Generator],
        taps: Int,
        prestigeCount: Int,
        stellarShards: Int,
        clickUpgrades: [ClickUpgrade],
        creditsPerSecond: Double
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for index in achievements.indices {
            // Skip already unlocked achievements
            guard !achievements[index].isUnlocked else { continue }

            let achievement = achievements[index]
            var currentValue: Double = 0

            // Determine current value based on requirement type
            switch achievement.requirementType {
            case .credits:
                currentValue = totalCreditsEarned

            case .generators:
                currentValue = Double(generators.filter { $0.isUnlocked }.count)

            case .generatorLevel:
                // For specific generator achievements, check the highest level
                currentValue = Double(generators.map { $0.level }.max() ?? 0)

            case .taps:
                currentValue = Double(taps)

            case .prestigeCount:
                currentValue = Double(prestigeCount)

            case .stellarShards:
                currentValue = Double(stellarShards)

            case .clickUpgrades:
                currentValue = Double(clickUpgrades.filter { $0.isUnlocked }.count)

            case .creditsPerSecond:
                currentValue = creditsPerSecond
            }

            // Check if requirement is met
            if currentValue >= achievement.targetValue {
                achievements[index].isUnlocked = true
                newlyUnlocked.append(achievements[index])
            }
        }

        return newlyUnlocked
    }

    // MARK: - Default Achievements

    /// Creates the default set of 20+ achievements
    private static func createDefaultAchievements() -> [Achievement] {
        return [
            // Credits Milestones
            Achievement(
                title: "First Earnings",
                description: "Earn 1,000 total credits",
                iconName: "dollarsign.circle.fill",
                requirementType: .credits,
                targetValue: 1_000,
                rewardMultiplier: 0.02
            ),
            Achievement(
                title: "Getting Rich",
                description: "Earn 10,000 total credits",
                iconName: "dollarsign.circle.fill",
                requirementType: .credits,
                targetValue: 10_000,
                rewardMultiplier: 0.03
            ),
            Achievement(
                title: "Space Tycoon",
                description: "Earn 100,000 total credits",
                iconName: "banknote.fill",
                requirementType: .credits,
                targetValue: 100_000,
                rewardMultiplier: 0.05
            ),
            Achievement(
                title: "Millionaire",
                description: "Earn 1,000,000 total credits",
                iconName: "crown.fill",
                requirementType: .credits,
                targetValue: 1_000_000,
                rewardMultiplier: 0.08
            ),
            Achievement(
                title: "Billionaire",
                description: "Earn 1,000,000,000 total credits",
                iconName: "star.circle.fill",
                requirementType: .credits,
                targetValue: 1_000_000_000,
                rewardMultiplier: 0.10
            ),

            // Generator Achievements
            Achievement(
                title: "Starting Fleet",
                description: "Unlock 2 different generators",
                iconName: "antenna.radiowaves.left.and.right",
                requirementType: .generators,
                targetValue: 2,
                rewardMultiplier: 0.03
            ),
            Achievement(
                title: "Expanding Empire",
                description: "Unlock 4 different generators",
                iconName: "sparkles",
                requirementType: .generators,
                targetValue: 4,
                rewardMultiplier: 0.05
            ),
            Achievement(
                title: "Full Arsenal",
                description: "Unlock all 6 generators",
                iconName: "star.fill",
                requirementType: .generators,
                targetValue: 6,
                rewardMultiplier: 0.10
            ),
            Achievement(
                title: "Master Operator",
                description: "Upgrade any generator to level 50",
                iconName: "bolt.fill",
                requirementType: .generatorLevel,
                targetValue: 50,
                rewardMultiplier: 0.07
            ),
            Achievement(
                title: "Legendary Engineer",
                description: "Upgrade any generator to level 100",
                iconName: "atom",
                requirementType: .generatorLevel,
                targetValue: 100,
                rewardMultiplier: 0.12
            ),

            // Click/Tap Achievements
            Achievement(
                title: "Button Masher",
                description: "Perform 1,000 taps",
                iconName: "hand.tap.fill",
                requirementType: .taps,
                targetValue: 1_000,
                rewardMultiplier: 0.02
            ),
            Achievement(
                title: "Click Commander",
                description: "Perform 10,000 taps",
                iconName: "hand.tap.fill",
                requirementType: .taps,
                targetValue: 10_000,
                rewardMultiplier: 0.05
            ),
            Achievement(
                title: "Tap Titan",
                description: "Perform 100,000 taps",
                iconName: "hand.raised.fill",
                requirementType: .taps,
                targetValue: 100_000,
                rewardMultiplier: 0.10
            ),

            // Click Upgrade Achievements
            Achievement(
                title: "Enhanced Clicking",
                description: "Unlock 2 click upgrades",
                iconName: "hand.point.up.fill",
                requirementType: .clickUpgrades,
                targetValue: 2,
                rewardMultiplier: 0.03
            ),
            Achievement(
                title: "Ultimate Clicker",
                description: "Unlock all click upgrades",
                iconName: "waveform.path",
                requirementType: .clickUpgrades,
                targetValue: 5,
                rewardMultiplier: 0.08
            ),

            // Prestige Achievements
            Achievement(
                title: "First Ascension",
                description: "Prestige for the first time",
                iconName: "sparkles",
                requirementType: .prestigeCount,
                targetValue: 1,
                rewardMultiplier: 0.05
            ),
            Achievement(
                title: "Ascension Master",
                description: "Prestige 5 times",
                iconName: "sparkle",
                requirementType: .prestigeCount,
                targetValue: 5,
                rewardMultiplier: 0.08
            ),
            Achievement(
                title: "Eternal Ascendant",
                description: "Prestige 10 times",
                iconName: "diamond.fill",
                requirementType: .prestigeCount,
                targetValue: 10,
                rewardMultiplier: 0.15
            ),

            // Stellar Shards Achievements
            Achievement(
                title: "Shard Collector",
                description: "Earn 10 total Stellar Shards",
                iconName: "diamond",
                requirementType: .stellarShards,
                targetValue: 10,
                rewardMultiplier: 0.05
            ),
            Achievement(
                title: "Shard Hoarder",
                description: "Earn 50 total Stellar Shards",
                iconName: "diamond.fill",
                requirementType: .stellarShards,
                targetValue: 50,
                rewardMultiplier: 0.10
            ),
            Achievement(
                title: "Cosmic Collector",
                description: "Earn 100 total Stellar Shards",
                iconName: "sparkles",
                requirementType: .stellarShards,
                targetValue: 100,
                rewardMultiplier: 0.20
            ),

            // Production Rate Achievements
            Achievement(
                title: "Steady Income",
                description: "Reach 100 credits per second",
                iconName: "arrow.up.circle.fill",
                requirementType: .creditsPerSecond,
                targetValue: 100,
                rewardMultiplier: 0.03
            ),
            Achievement(
                title: "Production Powerhouse",
                description: "Reach 1,000 credits per second",
                iconName: "arrow.up.circle.fill",
                requirementType: .creditsPerSecond,
                targetValue: 1_000,
                rewardMultiplier: 0.05
            ),
            Achievement(
                title: "Industrial Giant",
                description: "Reach 10,000 credits per second",
                iconName: "arrow.triangle.2.circlepath.circle.fill",
                requirementType: .creditsPerSecond,
                targetValue: 10_000,
                rewardMultiplier: 0.08
            ),
            Achievement(
                title: "Galactic Empire",
                description: "Reach 100,000 credits per second",
                iconName: "sun.max.fill",
                requirementType: .creditsPerSecond,
                targetValue: 100_000,
                rewardMultiplier: 0.15
            )
        ]
    }
}
