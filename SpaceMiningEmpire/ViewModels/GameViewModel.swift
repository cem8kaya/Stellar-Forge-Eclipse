import Foundation
import Combine
import UIKit
import SwiftUI

/// Data point for production history chart
struct ProductionDataPoint: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let creditsPerSecond: Double

    init(timestamp: Date, creditsPerSecond: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.creditsPerSecond = creditsPerSecond
    }
}

/// Daily activity data for heatmap
struct DailyActivityData: Codable, Identifiable {
    let id: UUID
    let date: Date
    let tapCount: Int
    let creditsEarned: Double

    init(date: Date, tapCount: Int, creditsEarned: Double) {
        self.id = UUID()
        self.date = date
        self.tapCount = tapCount
        self.creditsEarned = creditsEarned
    }
}

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

    /// Whether to show the statistics modal
    @Published var isShowingStatsModal: Bool = false

    /// Total time played in seconds
    @Published var totalTimePlayed: TimeInterval = 0.0

    /// Peak credits per second achieved
    @Published var peakCreditsPerSecond: Double = 0.0

    /// Session start time
    @Published var sessionStartTime: Date = Date()

    /// Session start credits
    @Published var sessionStartCredits: Double = 0.0

    /// Session taps
    @Published var sessionTaps: Int = 0

    /// Production history data points (time: timestamp, value: CPS)
    @Published var productionHistory: [ProductionDataPoint] = []

    /// Total upgrades purchased (generators + click upgrades)
    @Published var totalUpgradesPurchased: Int = 0

    /// Daily activity data (date: day identifier, taps: tap count)
    @Published var dailyActivity: [DailyActivityData] = []

    /// Settings reference for preferences
    var settings = Settings.shared

    /// Notification badges for affordability
    @Published var affordableGeneratorIDs: Set<UUID> = []
    @Published var affordableUpgradeIDs: Set<UUID> = []

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

    /// UserDefaults key for total time played
    private let totalTimePlayedKey = "totalTimePlayed"

    /// UserDefaults key for peak credits per second
    private let peakCreditsPerSecondKey = "peakCreditsPerSecond"

    /// UserDefaults key for production history
    private let productionHistoryKey = "productionHistory"

    /// UserDefaults key for total upgrades purchased
    private let totalUpgradesPurchasedKey = "totalUpgradesPurchased"

    /// UserDefaults key for daily activity
    private let dailyActivityKey = "dailyActivity"

    /// Timer for tracking session time
    private var timeTrackingTimer: AnyCancellable?

    /// Maximum number of production history points to keep (last 60 data points = 1 hour at 1-minute intervals)
    private let maxProductionHistoryPoints = 60

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

    /// Most valuable generator (by production)
    var mostValuableGenerator: Generator? {
        generators.max { a, b in
            a.currentProductionPerSecond < b.currentProductionPerSecond
        }
    }

    /// Total session time in seconds
    var sessionTimePlayed: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }

    /// Session credits earned
    var sessionCreditsEarned: Double {
        totalCreditsEarned - sessionStartCredits
    }

    /// Achievement completion percentage
    var achievementCompletionPercentage: Double {
        let total = Double(achievementManager.achievements.count)
        guard total > 0 else { return 0 }
        let unlocked = Double(achievementManager.unlockedCount)
        return (unlocked / total) * 100
    }

    // MARK: - Initialization

    init() {
        loadGame()
        initializeGenerators()
        initializeClickUpgrades()
        calculateCreditsPerTap()
        calculateOfflineEarnings()
        startProduction()
        startTimeTracking()
        initializeSession()
    }

    /// Initializes session tracking variables
    private func initializeSession() {
        sessionStartTime = Date()
        sessionStartCredits = totalCreditsEarned
        sessionTaps = 0
    }

    /// Starts the time tracking timer that updates total time played
    private func startTimeTracking() {
        // Update time played every minute
        timeTrackingTimer = Timer.publish(every: 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.totalTimePlayed += 60.0
                self.updateDailyActivity()
                self.saveGame()
            }
    }

    /// Updates daily activity tracking
    private func updateDailyActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find or create today's activity data
        if let index = dailyActivity.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            // Update existing entry
            var activity = dailyActivity[index]
            activity = DailyActivityData(
                date: activity.date,
                tapCount: activity.tapCount + sessionTaps,
                creditsEarned: activity.creditsEarned + sessionCreditsEarned
            )
            dailyActivity[index] = activity
        } else {
            // Create new entry
            let newActivity = DailyActivityData(
                date: today,
                tapCount: sessionTaps,
                creditsEarned: sessionCreditsEarned
            )
            dailyActivity.append(newActivity)
        }

        // Keep only last 30 days
        if dailyActivity.count > 30 {
            dailyActivity = Array(dailyActivity.suffix(30))
        }
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

        // Track peak CPS
        if totalProductionPerSecond > peakCreditsPerSecond {
            peakCreditsPerSecond = totalProductionPerSecond
        }

        // Update production history every 60 seconds
        updateProductionHistory(totalProductionPerSecond)

        // Add production to credits
        credits += totalProductionPerSecond

        // Track total credits earned
        totalCreditsEarned += totalProductionPerSecond

        // Update affordability tracking
        updateAffordability()

        // Perform auto-buy if enabled
        performAutoBuy()

        // Check achievements
        checkAndUnlockAchievements()
    }

    /// Production history update counter
    private var productionHistoryUpdateCounter = 0

    /// Updates production history data points
    private func updateProductionHistory(_ cps: Double) {
        productionHistoryUpdateCounter += 1

        // Record a data point every 60 seconds (60 ticks)
        guard productionHistoryUpdateCounter >= 60 else { return }
        productionHistoryUpdateCounter = 0

        let dataPoint = ProductionDataPoint(
            timestamp: Date(),
            creditsPerSecond: cps
        )
        productionHistory.append(dataPoint)

        // Keep only the last maxProductionHistoryPoints
        if productionHistory.count > maxProductionHistoryPoints {
            productionHistory.removeFirst()
        }
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

        // Track upgrade purchase
        totalUpgradesPurchased += 1

        // Add haptic feedback if enabled
        if settings.hapticFeedbackEnabled {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }

        // Save game state
        saveGame()
    }

    /// Buys a specific quantity of a generator
    /// - Parameters:
    ///   - generatorID: The UUID of the generator
    ///   - quantity: Number of levels to buy
    func buyGenerator(generatorID: UUID, quantity: Int) {
        guard let index = generators.firstIndex(where: { $0.id == generatorID }) else {
            return
        }

        var generator = generators[index]
        var totalCost = 0.0
        var levelsPurchased = 0

        // Calculate total cost for buying quantity levels
        for i in 0..<quantity {
            let nextCost = generator.baseCost * pow(1.15, Double(generator.level + i))
            if credits >= totalCost + nextCost {
                totalCost += nextCost
                levelsPurchased += 1
            } else {
                break
            }
        }

        // If we can't buy any, return
        guard levelsPurchased > 0 else { return }

        // Deduct cost and add levels
        credits -= totalCost
        generators[index].level += levelsPurchased

        // Track upgrades purchased
        totalUpgradesPurchased += levelsPurchased

        // Add haptic feedback if enabled
        if settings.hapticFeedbackEnabled {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }

        // Save game state
        saveGame()
    }

    /// Calculates the maximum number of levels that can be purchased for a generator
    /// - Parameter generatorID: The UUID of the generator
    /// - Returns: Maximum affordable levels
    func maxAffordableLevels(for generatorID: UUID) -> Int {
        guard let generator = generators.first(where: { $0.id == generatorID }) else {
            return 0
        }

        var currentCredits = credits
        var levels = 0
        var currentLevel = generator.level

        // Keep buying while we have credits
        while levels < 1000 { // Cap at 1000 to prevent infinite loops
            let nextCost = generator.baseCost * pow(1.15, Double(currentLevel))
            if currentCredits >= nextCost {
                currentCredits -= nextCost
                currentLevel += 1
                levels += 1
            } else {
                break
            }
        }

        return levels
    }

    /// Buys the maximum affordable levels for a generator
    /// - Parameter generatorID: The UUID of the generator
    func buyMaxGenerator(generatorID: UUID) {
        let maxLevels = maxAffordableLevels(for: generatorID)
        if maxLevels > 0 {
            buyGenerator(generatorID: generatorID, quantity: maxLevels)
        }
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
        sessionTaps += 1

        // Add haptic feedback if enabled
        if settings.hapticFeedbackEnabled {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }

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

        // Track upgrade purchase
        totalUpgradesPurchased += 1

        // Recalculate credits per tap
        calculateCreditsPerTap()

        // Add haptic feedback if enabled
        if settings.hapticFeedbackEnabled {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }

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

        // Add strong haptic feedback for prestige if enabled
        if settings.hapticFeedbackEnabled {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }

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

            // Add haptic feedback for achievement unlock if enabled
            if settings.hapticFeedbackEnabled {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }

            // Save the updated achievement state
            saveGame()
        }
    }

    // MARK: - Auto-Buy & Affordability Functions

    /// Updates the affordability tracking for generators and upgrades
    private func updateAffordability() {
        guard settings.affordabilityNotificationsEnabled else {
            affordableGeneratorIDs.removeAll()
            affordableUpgradeIDs.removeAll()
            return
        }

        // Track affordable generators
        var newAffordableGenerators = Set<UUID>()
        for generator in generators {
            if credits >= generator.nextLevelCost {
                newAffordableGenerators.insert(generator.id)
            }
        }
        affordableGeneratorIDs = newAffordableGenerators

        // Track affordable upgrades
        var newAffordableUpgrades = Set<UUID>()
        for upgrade in clickUpgrades {
            if credits >= upgrade.nextLevelCost {
                newAffordableUpgrades.insert(upgrade.id)
            }
        }
        affordableUpgradeIDs = newAffordableUpgrades
    }

    /// Performs auto-buy for generators that have auto-buy enabled
    private func performAutoBuy() {
        guard settings.autoBuyEnabled else { return }

        for generator in generators {
            // Check if auto-buy is enabled for this generator
            guard settings.isAutoBuyEnabled(for: generator.id.uuidString) else { continue }

            // Try to buy if affordable
            if credits >= generator.nextLevelCost {
                levelUp(generatorID: generator.id)
            }
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

        // Save statistics
        userDefaults.set(totalTimePlayed, forKey: totalTimePlayedKey)
        userDefaults.set(peakCreditsPerSecond, forKey: peakCreditsPerSecondKey)
        userDefaults.set(totalUpgradesPurchased, forKey: totalUpgradesPurchasedKey)

        // Encode and save production history
        do {
            let encodedData = try JSONEncoder().encode(productionHistory)
            userDefaults.set(encodedData, forKey: productionHistoryKey)
        } catch {
            print("Error encoding production history: \(error)")
        }

        // Encode and save daily activity
        do {
            let encodedData = try JSONEncoder().encode(dailyActivity)
            userDefaults.set(encodedData, forKey: dailyActivityKey)
        } catch {
            print("Error encoding daily activity: \(error)")
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

        // Load statistics
        totalTimePlayed = userDefaults.double(forKey: totalTimePlayedKey)
        peakCreditsPerSecond = userDefaults.double(forKey: peakCreditsPerSecondKey)
        totalUpgradesPurchased = userDefaults.integer(forKey: totalUpgradesPurchasedKey)

        // Load and decode production history
        if let savedData = userDefaults.data(forKey: productionHistoryKey) {
            do {
                productionHistory = try JSONDecoder().decode([ProductionDataPoint].self, from: savedData)
            } catch {
                print("Error decoding production history: \(error)")
                productionHistory = []
            }
        }

        // Load and decode daily activity
        if let savedData = userDefaults.data(forKey: dailyActivityKey) {
            do {
                dailyActivity = try JSONDecoder().decode([DailyActivityData].self, from: savedData)
            } catch {
                print("Error decoding daily activity: \(error)")
                dailyActivity = []
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
        timeTrackingTimer?.cancel()
    }
}
