import Foundation

/// Manages the prestige system, including Stellar Shards calculation and multipliers
struct PrestigeManager: Codable {
    // MARK: - Properties

    /// Total Stellar Shards earned from all-time prestiges
    var stellarShards: Int

    /// Total number of times the player has prestiged
    var lifetimePrestigeCount: Int

    // MARK: - Computed Properties

    /// Prestige multiplier applied to all production
    /// Formula: 1 + (stellarShards * 0.1)
    var prestigeMultiplier: Double {
        1.0 + (Double(stellarShards) * 0.1)
    }

    // MARK: - Initialization

    init(stellarShards: Int = 0, lifetimePrestigeCount: Int = 0) {
        self.stellarShards = stellarShards
        self.lifetimePrestigeCount = lifetimePrestigeCount
    }

    // MARK: - Functions

    /// Calculates potential Stellar Shards from total credits earned
    /// Formula: floor(sqrt(totalCreditsEarned / 1_000_000))
    /// - Parameter totalCreditsEarned: Total credits earned across the current run
    /// - Returns: Number of Stellar Shards that would be earned
    static func calculateStellarShards(from totalCreditsEarned: Double) -> Int {
        guard totalCreditsEarned >= 1_000_000 else { return 0 }
        return Int(floor(sqrt(totalCreditsEarned / 1_000_000.0)))
    }

    /// Performs a prestige, adding new shards and incrementing count
    /// - Parameter newShards: Number of new shards earned from this prestige
    mutating func performPrestige(newShards: Int) {
        stellarShards += newShards
        lifetimePrestigeCount += 1
    }
}
