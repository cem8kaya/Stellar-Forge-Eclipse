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

    /// Maximum offline time in seconds (24 hours)
    private let maxOfflineTime: TimeInterval = 86400

    // MARK: - Initialization

    init() {
        loadGame()
        initializeGenerators()
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
        let totalProductionPerSecond = generators.reduce(0.0) { total, generator in
            total + generator.currentProductionPerSecond
        }

        // Update published property for UI display
        self.totalCreditsPerSecond = totalProductionPerSecond

        // Add production to credits
        credits += totalProductionPerSecond
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

    // MARK: - Persistence Functions

    /// Saves the current game state to UserDefaults
    func saveGame() {
        // Save credits
        userDefaults.set(credits, forKey: creditsKey)

        // Encode and save generators
        do {
            let encodedData = try JSONEncoder().encode(generators)
            userDefaults.set(encodedData, forKey: generatorsKey)
        } catch {
            print("Error encoding generators: \(error)")
        }

        // Save current timestamp
        userDefaults.set(Date().timeIntervalSince1970, forKey: lastSaveTimeKey)
    }

    /// Loads the saved game state from UserDefaults
    private func loadGame() {
        // Load credits
        credits = userDefaults.double(forKey: creditsKey)

        // Load and decode generators
        if let savedData = userDefaults.data(forKey: generatorsKey) {
            do {
                generators = try JSONDecoder().decode([Generator].self, from: savedData)
            } catch {
                print("Error decoding generators: \(error)")
                generators = []
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
        let totalProduction = generators.reduce(0.0) { total, generator in
            total + generator.currentProductionPerSecond
        }

        // Calculate earnings
        let earnings = totalProduction * timeDifference

        // Only show modal if earnings are significant
        if earnings >= 1.0 {
            offlineEarnings = earnings
            credits += earnings
            isShowingOfflineModal = true
            saveGame()
        }
    }

    // MARK: - Cleanup

    deinit {
        timer?.cancel()
    }
}
