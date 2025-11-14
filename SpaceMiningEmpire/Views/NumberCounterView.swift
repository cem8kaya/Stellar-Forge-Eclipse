import SwiftUI

/// Animated number counter that smoothly transitions from old to new values
struct NumberCounterView: View {
    // MARK: - Properties

    let value: Double
    let font: Font
    let foregroundColor: Color

    @State private var displayValue: Double = 0

    // MARK: - Body

    var body: some View {
        Text(displayValue.formattedCredits)
            .font(font)
            .foregroundColor(foregroundColor)
            .contentTransition(.numericText(value: displayValue))
            .onChange(of: value) { oldValue, newValue in
                // Animate the transition from old to new value
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    displayValue = newValue
                }
            }
            .onAppear {
                // Initialize with the current value
                displayValue = value
            }
    }
}

/// Animated number counter with customizable format
struct AnimatedNumberView: View {
    // MARK: - Properties

    let value: Double
    let font: Font
    let foregroundColor: Color
    let format: NumberFormat

    @State private var displayValue: Double = 0

    enum NumberFormat {
        case credits
        case decimal(places: Int)
        case integer
    }

    // MARK: - Body

    var body: some View {
        Text(formattedValue)
            .font(font)
            .foregroundColor(foregroundColor)
            .contentTransition(.numericText(value: displayValue))
            .onChange(of: value) { oldValue, newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    displayValue = newValue
                }
            }
            .onAppear {
                displayValue = value
            }
    }

    // MARK: - Helpers

    private var formattedValue: String {
        switch format {
        case .credits:
            return displayValue.formattedCredits
        case .decimal(let places):
            return String(format: "%.\(places)f", displayValue)
        case .integer:
            return "\(Int(displayValue))"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        NumberCounterView(
            value: 12345678.9,
            font: .system(size: 42, weight: .bold, design: .rounded),
            foregroundColor: .white
        )

        AnimatedNumberView(
            value: 2.5,
            font: .title,
            foregroundColor: .cyan,
            format: .decimal(places: 1)
        )
    }
    .padding()
    .background(Color.black)
}
