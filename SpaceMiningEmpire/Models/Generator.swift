import Foundation

/// Represents a generator that produces credits over time in the Space Mining Empire
struct Generator: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// Unique identifier for the generator
    let id: UUID

    /// Display name of the generator (e.g., "Mining Probe")
    let name: String

    /// Current level of the generator (0 = locked, 1+ = unlocked)
    var level: Int

    /// Initial purchase cost for level 1
    let baseCost: Double

    /// Credits produced per second at level 1
    let baseProduction: Double

    /// SF Symbol name for visual representation
    let iconName: String

    // MARK: - Computed Properties

    /// Cost to upgrade to the next level
    /// Formula: baseCost * 1.15^level
    var nextLevelCost: Double {
        baseCost * pow(1.15, Double(level))
    }

    /// Current production rate in credits per second
    /// Returns 0 if the generator is locked (level 0)
    var currentProductionPerSecond: Double {
        baseProduction * Double(level)
    }

    /// Whether the generator has been unlocked (level > 0)
    var isUnlocked: Bool {
        level > 0
    }

    // MARK: - Initialization

    init(id: UUID = UUID(), name: String, level: Int = 0, baseCost: Double, baseProduction: Double, iconName: String) {
        self.id = id
        self.name = name
        self.level = level
        self.baseCost = baseCost
        self.baseProduction = baseProduction
        self.iconName = iconName
    }
}
