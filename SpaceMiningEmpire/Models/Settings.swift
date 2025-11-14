import Foundation
import SwiftUI

class Settings: ObservableObject {
    static let shared = Settings()

    // MARK: - Haptics & Sound
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
    @AppStorage("soundEffectsEnabled") var soundEffectsEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true

    // MARK: - Display & Formatting
    @AppStorage("notationStyle") var notationStyle: NotationStyle = .abbreviated
    @AppStorage("themeSelection") var themeSelection: Theme = .dark

    // MARK: - Gameplay
    @AppStorage("confirmPurchases") var confirmPurchases: Bool = false
    @AppStorage("showTutorial") var showTutorial: Bool = true
    @AppStorage("autoBuyEnabled") var autoBuyEnabled: Bool = false

    // MARK: - Notifications
    @AppStorage("affordabilityNotificationsEnabled") var affordabilityNotificationsEnabled: Bool = true
    @AppStorage("achievementNotificationsEnabled") var achievementNotificationsEnabled: Bool = true

    // MARK: - Auto-buy settings per generator
    private let autoBuyGeneratorsKey = "autoBuyGenerators"

    func isAutoBuyEnabled(for generatorID: String) -> Bool {
        let autoBuyDict = UserDefaults.standard.dictionary(forKey: autoBuyGeneratorsKey) as? [String: Bool] ?? [:]
        return autoBuyDict[generatorID] ?? false
    }

    func setAutoBuy(for generatorID: String, enabled: Bool) {
        var autoBuyDict = UserDefaults.standard.dictionary(forKey: autoBuyGeneratorsKey) as? [String: Bool] ?? [:]
        autoBuyDict[generatorID] = enabled
        UserDefaults.standard.set(autoBuyDict, forKey: autoBuyGeneratorsKey)
        objectWillChange.send()
    }

    // MARK: - Enums
    enum NotationStyle: String, CaseIterable {
        case abbreviated = "Abbreviated" // 1.5K
        case full = "Full" // 1,500

        var displayName: String {
            return self.rawValue
        }

        var example: String {
            switch self {
            case .abbreviated:
                return "1.5K, 2.3M, 4.7B"
            case .full:
                return "1,500, 2,300,000"
            }
        }
    }

    enum Theme: String, CaseIterable {
        case dark = "Dark"
        case light = "Light"
        case cosmic = "Cosmic"
        case nebula = "Nebula"

        var displayName: String {
            return self.rawValue
        }

        var primaryColor: Color {
            switch self {
            case .dark:
                return .blue
            case .light:
                return .purple
            case .cosmic:
                return .cyan
            case .nebula:
                return .pink
            }
        }

        var secondaryColor: Color {
            switch self {
            case .dark:
                return .purple
            case .light:
                return .blue
            case .cosmic:
                return .green
            case .nebula:
                return .orange
            }
        }

        var backgroundColor: Color {
            switch self {
            case .dark:
                return Color(red: 0.05, green: 0.05, blue: 0.1)
            case .light:
                return Color(red: 0.9, green: 0.9, blue: 0.95)
            case .cosmic:
                return Color(red: 0.0, green: 0.1, blue: 0.2)
            case .nebula:
                return Color(red: 0.15, green: 0.05, blue: 0.15)
            }
        }
    }
}

// MARK: - Number Formatting Extension
extension Double {
    func formatted(using style: Settings.NotationStyle) -> String {
        switch style {
        case .abbreviated:
            return self.formattedCredits
        case .full:
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self))"
        }
    }
}
