import Foundation

/// Represents an upgrade that increases credits earned per tap
struct ClickUpgrade: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// Unique identifier for the upgrade
    let id: UUID

    /// Display name of the upgrade (e.g., "Quantum Clicker")
    let name: String

    /// Current level of the upgrade (0 = locked, 1+ = unlocked)
    var level: Int

    /// Initial purchase cost for level 1
    let baseCost: Double

    /// Credits added per tap at level 1
    let baseMultiplier: Double

    /// SF Symbol name for visual representation
    let iconName: String

    // MARK: - Computed Properties

    /// Cost to upgrade to the next level
    /// Formula: baseCost * 2^level (exponential scaling)
    var nextLevelCost: Double {
        baseCost * pow(2.0, Double(level))
    }

    /// Current multiplier added to credits per tap
    /// Returns 0 if the upgrade is locked (level 0)
    var currentMultiplier: Double {
        baseMultiplier * Double(level)
    }

    /// Whether the upgrade has been unlocked (level > 0)
    var isUnlocked: Bool {
        level > 0
    }

    // MARK: - Initialization

    init(id: UUID = UUID(), name: String, level: Int = 0, baseCost: Double, baseMultiplier: Double, iconName: String) {
        self.id = id
        self.name = name
        self.level = level
        self.baseCost = baseCost
        self.baseMultiplier = baseMultiplier
        self.iconName = iconName
    }
}
