import Foundation

/// Represents an achievement that can be unlocked in the game
struct Achievement: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// Unique identifier for the achievement
    let id: UUID

    /// Display title of the achievement
    let title: String

    /// Description of how to unlock the achievement
    let description: String

    /// SF Symbol name for visual representation
    let iconName: String

    /// Type of requirement to unlock the achievement
    let requirementType: RequirementType

    /// Target value that must be reached to unlock
    let targetValue: Double

    /// Whether this achievement has been unlocked
    var isUnlocked: Bool

    /// Multiplier bonus granted when unlocked (e.g., 0.05 = +5%)
    let rewardMultiplier: Double

    // MARK: - Nested Types

    /// Types of requirements for unlocking achievements
    enum RequirementType: String, Codable {
        case credits              // Total credits earned
        case generators           // Number of generators unlocked
        case generatorLevel       // Specific generator level
        case taps                 // Total taps performed
        case prestigeCount        // Number of prestiges
        case stellarShards        // Total stellar shards earned
        case clickUpgrades        // Number of click upgrades unlocked
        case creditsPerSecond     // Production per second milestone
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        iconName: String,
        requirementType: RequirementType,
        targetValue: Double,
        isUnlocked: Bool = false,
        rewardMultiplier: Double
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.requirementType = requirementType
        self.targetValue = targetValue
        self.isUnlocked = isUnlocked
        self.rewardMultiplier = rewardMultiplier
    }

    // MARK: - Functions

    /// Calculates the current progress towards this achievement (0.0 to 1.0)
    /// - Parameter currentValue: The current value to compare against the target
    /// - Returns: Progress as a fraction between 0 and 1
    func progress(currentValue: Double) -> Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
}
