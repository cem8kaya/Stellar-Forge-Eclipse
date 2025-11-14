import Foundation

/// Extension to format Double values as abbreviated credit strings
extension Double {
    /// Formats the double value as a credits string with K, M, B, T abbreviations
    ///
    /// Examples:
    /// - 500 -> "500"
    /// - 1500 -> "1.5K"
    /// - 2300000 -> "2.3M"
    /// - 5700000000 -> "5.7B"
    /// - 1200000000000 -> "1.2T"
    var formattedCredits: String {
        switch self {
        case 0..<1_000:
            return String(format: "%.0f", self)
        case 1_000..<1_000_000:
            return String(format: "%.1fK", self / 1_000)
        case 1_000_000..<1_000_000_000:
            return String(format: "%.1fM", self / 1_000_000)
        case 1_000_000_000..<1_000_000_000_000:
            return String(format: "%.1fB", self / 1_000_000_000)
        default:
            return String(format: "%.1fT", self / 1_000_000_000_000)
        }
    }
}
