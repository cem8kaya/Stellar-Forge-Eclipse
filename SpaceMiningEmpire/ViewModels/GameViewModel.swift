import Foundation
import Combine
import UIKit

/// ViewModel that manages the game state, generators, credits, and persistence
class GameViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Current credits balance
    @Published var credits: Double = 0.0

    /// Array of all generators in the game
    @Published var generators: [Generator] = []

    /// Credits earned while the app was closed
    @Published var offlineEarnings: Double = 0.0

    /// Whether to show the offline earnings modal
    @Published var isShowingOfflineModal: Bool = false

    /// Total credits produced per second (for UI display)
    @Published var totalCreditsPerSecond: Double = 0.0

    /// Credits earned per manual tap
    @Published var creditsPerTap: Double = 1.0

    /// Total number of taps performed (for statistics)
    @Published var totalTaps: Int = 0

    /// Array of all click/tap upgrades in the game
    @Published var clickUpgrades: [ClickUpgrade] = []

    /// Total credits earned across all time (including resets)
    @Published var totalCreditsEarned: Double = 0.0

    /// Prestige manager that handles Stellar Shards and multipliers
    @Published var prestigeManager: PrestigeManager = PrestigeManager()

    /// Whether to show the prestige modal
    @Published var isShowingPrestigeModal: Bool = false

    /// Achievement manager that handles all achievements
    @Published var achievementManager: AchievementManager = AchievementManager()

    /// Whether to show the achievements modal
    @Published var isShowingAchievementsModal: Bool = false

    /// Recently unlocked achievements (for displaying notifications)
    @Published var recentlyUnlockedAchievements: [Achievement] = []

    // MARK: - Private Properties

    /// Timer subscription for production updates
    private var timer: AnyCancellable?

    /// UserDefaults instance for persistence
    private let userDefaults = UserDefaults.standard

    /// UserDefaults key for saved credits
    private let creditsKey = "savedCredits"

    /// UserDefaults key for saved generators array
    private let generatorsKey = "savedGenerators"

    /// UserDefaults key for last save timestamp
    private let lastSaveTimeKey = "lastAppCloseTime"

    /// UserDefaults key for credits per tap
    private let creditsPerTapKey = "creditsPerTap"

    /// UserDefaults key for total taps
    private let totalTapsKey = "totalTaps"

    /// UserDefaults key for saved click upgrades array
    private let clickUpgradesKey = "savedClickUpgrades"

    /// Maximum offline time in seconds (24 hours)
    private let maxOfflineTime: TimeInterval = 86400

    /// UserDefaults key for total credits earned
    private let totalCreditsEarnedKey = "totalCreditsEarned"

    /// UserDefaults key for prestige manager
    private let prestigeManagerKey = "prestigeManager"

    /// UserDefaults key for achievement manager
    private let achievementManagerKey = "achievementManager"

    // MARK: - Computed Properties

    /// Current Stellar Shards from prestige manager
    var stellarShards: Int {
        prestigeManager.stellarShards
    }

    /// Current prestige multiplier
    var prestigeMultiplier: Double {
        prestigeManager.prestigeMultiplier
    }

    /// Potential Stellar Shards that would be earned from prestiging now
    var potentialStellarShards: Int {
        PrestigeManager.calculateStellarShards(from: totalCreditsEarned)
    }

    /// Whether the player can prestige (has earned at least 1M total credits)
    var canPrestige: Bool {
        totalCreditsEarned >= 1_000_000
    }

    /// Total achievement multiplier from all unlocked achievements
    var achievementMultiplier: Double {
        achievementManager.totalAchievementMultiplier
    }

    /// Combined multiplier from prestige and achievements
    var totalMultiplier: Double {
        prestigeMultiplier * achievementMultiplier
    }

    // MARK: - Initialization

    init() {
        loadGame()
        initializeGenerators()
        initializeClickUpgrades()
        calculateCreditsPerTap()
        calculateOfflineEarnings()
        startProduction()
    }

    // MARK: - Core Functions

    /// Initializes the default generators on first launch
    private func initializeGenerators() {
        // Only initialize if generators are empty (first launch)
        guard generators.isEmpty else { return }

        generators = [
            Generator(
                name: "Mining Probe",
                level: 1, // Start unlocked
                baseCost: 10,
                baseProduction: 1,
                iconName: "antenna.radiowaves.left.and.right"
            ),
            Generator(
                name: "Asteroid Harvester",
                level: 0, // Locked
                baseCost: 100,
                baseProduction: 10,
                iconName: "sparkles"
            ),
            Generator(
                name: "Quantum Drill",
                level: 0, // Locked
                baseCost: 1000,
                baseProduction: 50,
                iconName: "bolt.fill"
            ),
            Generator(
                name: "Fusion Reactor",
                level: 0, // Locked
                baseCost: 10000,
                baseProduction: 200,
                iconName: "atom"
            ),
            Generator(
                name: "Antimatter Generator",
                level: 0, // Locked
                baseCost: 100000,
                baseProduction: 1000,
                iconName: "sparkle"
            ),
            Generator(
                name: "Stellar Forge",
                level: 0, // Locked
                baseCost: 1000000,
                baseProduction: 5000,
                iconName: "sun.max.fill"
            )
        ]

        // Save initial state
        saveGame()
    }

    /// Initializes the default click upgrades on first launch
    private func initializeClickUpgrades() {
        // Only initialize if click upgrades are empty (first launch)
        guard clickUpgrades.isEmpty else { return }

        clickUpgrades = [
            ClickUpgrade(
                name: "Titanium Finger",
                level: 0, // Locked
                baseCost: 50,
                baseMultiplier: 1,
                iconName: "hand.tap.fill"
            ),
            ClickUpgrade(
                name: "Laser Pointer",
                level: 0, // Locked
                baseCost: 500,
                baseMultiplier: 5,
                iconName: "flashlight.on.fill"
            ),
            ClickUpgrade(
                name: "Quantum Clicker",
                level: 0, // Locked
                baseCost: 5000,
                baseMultiplier: 25,
                iconName: "waveform.path"
            ),
            ClickUpgrade(
                name: "Neural Amplifier",
                level: 0, // Locked
                baseCost: 50000,
                baseMultiplier: 100,
                iconName: "brain.head.profile"
            ),
            ClickUpgrade(
                name: "Reality Bender",
                level: 0, // Locked
                baseCost: 500000,
                baseMultiplier: 500,
                iconName: "sparkles"
            )
        ]

        // Save initial state
        saveGame()
    }

    /// Calculates total credits per tap from all upgrades
    private func calculateCreditsPerTap() {
        // Base tap value is 1.0
        var total = 1.0

        // Add multipliers from all unlocked click upgrades
        for upgrade in clickUpgrades {
            total += upgrade.currentMultiplier
        }

        creditsPerTap = total
    }

    /// Starts the production timer that generates credits every second
    private func startProduction() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.produce()
            }
    }

    /// Called every second to produce credits based on generators
    private func produce() {
        // Calculate total production per second
        let baseProduction = generators.reduce(0.0) { total, generator in
            total + generator.currentProductionPerSecond
        }

        // Apply prestige and achievement multipliers
        let totalProductionPerSecond = baseProduction * totalMultiplier

        // Update published property for UI display
        self.totalCreditsPerSecond = totalProductionPerSecond

        // Add production to credits
        credits += totalProductionPerSecond

        // Track total credits earned
        totalCreditsEarned += totalProductionPerSecond

        // Check achievements
        checkAndUnlockAchievements()
    }

    /// Levels up a generator if the player has enough credits
    /// - Parameter generatorID: The UUID of the generator to level up
    func levelUp(generatorID: UUID) {
        guard let index = generators.firstIndex(where: { $0.id == generatorID }) else {
            return
        }

        let generator = generators[index]
        let cost = generator.nextLevelCost

        // Check if player has enough credits
        guard credits >= cost else {
            return
        }

        // Deduct cost and level up
        credits -= cost
        generators[index].level += 1

        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Save game state
        saveGame()
    }

    /// Handles a manual tap/click on the tap button
    func handleTap() {
        // Apply prestige and achievement multipliers to tap earnings
        let earnedCredits = creditsPerTap * totalMultiplier

        // Add credits based on current tap multiplier
        credits += earnedCredits

        // Track total credits earned
        totalCreditsEarned += earnedCredits

        // Increment tap counter
        totalTaps += 1

        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        // Check achievements
        checkAndUnlockAchievements()
    }

    /// Levels up a click upgrade if the player has enough credits
    /// - Parameter upgradeID: The UUID of the click upgrade to level up
    func levelUpClickUpgrade(upgradeID: UUID) {
        guard let index = clickUpgrades.firstIndex(where: { $0.id == upgradeID }) else {
            return
        }

        let upgrade = clickUpgrades[index]
        let cost = upgrade.nextLevelCost

        // Check if player has enough credits
        guard credits >= cost else {
            return
        }

        // Deduct cost and level up
        credits -= cost
        clickUpgrades[index].level += 1

        // Recalculate credits per tap
        calculateCreditsPerTap()

        // Add haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Save game state
        saveGame()
    }

    /// Performs a prestige, resetting the game but awarding Stellar Shards
    func prestige() {
        // Calculate new shards to be earned
        let newShards = potentialStellarShards

        // Perform prestige in the manager
        prestigeManager.performPrestige(newShards: newShards)

        // Reset credits to 0
        credits = 0.0

        // Reset all generators to initial state
        generators = generators.map { generator in
            var reset = generator
            // Keep first generator at level 1, rest at 0
            reset.level = generator.name == "Mining Probe" ? 1 : 0
            return reset
        }

        // Reset all click upgrades to locked state
        clickUpgrades = clickUpgrades.map { upgrade in
            var reset = upgrade
            reset.level = 0
            return reset
        }

        // Recalculate credits per tap (should reset to 1.0)
        calculateCreditsPerTap()

        // Reset tap counter
        totalTaps = 0

        // Keep totalCreditsEarned so player can prestige again
        // (Don't reset this - it's cumulative across prestiges)

        // Add strong haptic feedback for prestige
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // Save the new game state
        saveGame()

        // Check achievements after prestige
        checkAndUnlockAchievements()
    }

    /// Checks all achievements and unlocks any that meet requirements
    private func checkAndUnlockAchievements() {
        let newlyUnlocked = achievementManager.checkAchievements(
            credits: credits,
            totalCreditsEarned: totalCreditsEarned,
            generators: generators,
            taps: totalTaps,
            prestigeCount: prestigeManager.lifetimePrestigeCount,
            stellarShards: stellarShards,
            clickUpgrades: clickUpgrades,
            creditsPerSecond: totalCreditsPerSecond
        )

        // If achievements were unlocked, show notifications
        if !newlyUnlocked.isEmpty {
            recentlyUnlockedAchievements.append(contentsOf: newlyUnlocked)

            // Add haptic feedback for achievement unlock
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            // Save the updated achievement state
            saveGame()
        }
    }

    // MARK: - Persistence Functions

    /// Saves the current game state to UserDefaults
    func saveGame() {
        // Save credits
        userDefaults.set(credits, forKey: creditsKey)

        // Save tap statistics
        userDefaults.set(creditsPerTap, forKey: creditsPerTapKey)
        userDefaults.set(totalTaps, forKey: totalTapsKey)

        // Save total credits earned
        userDefaults.set(totalCreditsEarned, forKey: totalCreditsEarnedKey)

        // Encode and save generators
        do {
            let encodedData = try JSONEncoder().encode(generators)
            userDefaults.set(encodedData, forKey: generatorsKey)
        } catch {
            print("Error encoding generators: \(error)")
        }

        // Encode and save click upgrades
        do {
            let encodedData = try JSONEncoder().encode(clickUpgrades)
            userDefaults.set(encodedData, forKey: clickUpgradesKey)
        } catch {
            print("Error encoding click upgrades: \(error)")
        }

        // Encode and save prestige manager
        do {
            let encodedData = try JSONEncoder().encode(prestigeManager)
            userDefaults.set(encodedData, forKey: prestigeManagerKey)
        } catch {
            print("Error encoding prestige manager: \(error)")
        }

        // Encode and save achievement manager
        do {
            let encodedData = try JSONEncoder().encode(achievementManager)
            userDefaults.set(encodedData, forKey: achievementManagerKey)
        } catch {
            print("Error encoding achievement manager: \(error)")
        }

        // Save current timestamp
        userDefaults.set(Date().timeIntervalSince1970, forKey: lastSaveTimeKey)
    }

    /// Loads the saved game state from UserDefaults
    private func loadGame() {
        // Load credits
        credits = userDefaults.double(forKey: creditsKey)

        // Load tap statistics
        creditsPerTap = userDefaults.double(forKey: creditsPerTapKey)
        if creditsPerTap == 0.0 {
            creditsPerTap = 1.0 // Default value on first launch
        }
        totalTaps = userDefaults.integer(forKey: totalTapsKey)

        // Load total credits earned
        totalCreditsEarned = userDefaults.double(forKey: totalCreditsEarnedKey)

        // Load and decode generators
        if let savedData = userDefaults.data(forKey: generatorsKey) {
            do {
                generators = try JSONDecoder().decode([Generator].self, from: savedData)
            } catch {
                print("Error decoding generators: \(error)")
                generators = []
            }
        }

        // Load and decode click upgrades
        if let savedData = userDefaults.data(forKey: clickUpgradesKey) {
            do {
                clickUpgrades = try JSONDecoder().decode([ClickUpgrade].self, from: savedData)
            } catch {
                print("Error decoding click upgrades: \(error)")
                clickUpgrades = []
            }
        }

        // Load and decode prestige manager
        if let savedData = userDefaults.data(forKey: prestigeManagerKey) {
            do {
                prestigeManager = try JSONDecoder().decode(PrestigeManager.self, from: savedData)
            } catch {
                print("Error decoding prestige manager: \(error)")
                prestigeManager = PrestigeManager()
            }
        }

        // Load and decode achievement manager
        if let savedData = userDefaults.data(forKey: achievementManagerKey) {
            do {
                achievementManager = try JSONDecoder().decode(AchievementManager.self, from: savedData)
            } catch {
                print("Error decoding achievement manager: \(error)")
                achievementManager = AchievementManager()
            }
        }
    }

    /// Calculates credits earned while the app was closed
    private func calculateOfflineEarnings() {
        // Get last save time
        guard let lastSaveTime = userDefaults.object(forKey: lastSaveTimeKey) as? TimeInterval else {
            // First launch - no offline earnings
            return
        }

        // Calculate time difference
        let currentTime = Date().timeIntervalSince1970
        var timeDifference = currentTime - lastSaveTime

        // Cap at maximum offline time (24 hours)
        timeDifference = min(timeDifference, maxOfflineTime)

        // Calculate total production from all generators
        let baseProduction = generators.reduce(0.0) { total, generator in
            total + generator.currentProductionPerSecond
        }

        // Apply prestige and achievement multipliers to offline earnings
        let totalProduction = baseProduction * totalMultiplier

        // Calculate earnings
        let earnings = totalProduction * timeDifference

        // Only show modal if earnings are significant
        if earnings >= 1.0 {
            offlineEarnings = earnings
            credits += earnings
            totalCreditsEarned += earnings
            isShowingOfflineModal = true
            saveGame()
        }
    }

    // MARK: - Cleanup

    deinit {
        timer?.cancel()
    }
}
