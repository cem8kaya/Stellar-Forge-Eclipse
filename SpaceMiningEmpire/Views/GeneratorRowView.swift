import SwiftUI

/// View component that displays a single generator row with icon, stats, and upgrade button
struct GeneratorRowView: View {
    // MARK: - Properties

    let generator: Generator
    @ObservedObject var viewModel: GameViewModel

    @State private var isPulsing = false
    @State private var celebrationTriggered = false
    @State private var iconRotation: Double = 0

    private var isAffordable: Bool {
        viewModel.credits >= generator.nextLevelCost
    }

    private var progressToNextLevel: Double {
        guard generator.level > 0 else { return 0 }
        let currentCost = generator.nextLevelCost
        let previousCost = generator.baseCost * pow(1.15, Double(generator.level - 1))
        let progress = min(1.0, viewModel.credits / currentCost)
        return max(0, min(1.0, progress))
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Left: Icon + Info
                HStack(spacing: 12) {
                    // Generator Icon with animations
                    ZStack {
                        // Background glow for active generators
                        if generator.level > 0 {
                            Circle()
                                .fill(Color.cyan.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .blur(radius: 8)
                                .scaleEffect(isPulsing ? 1.2 : 1.0)
                                .opacity(isPulsing ? 0.8 : 0.5)
                        }

                        Image(systemName: generator.iconName)
                            .font(.title2)
                            .foregroundColor(.cyan)
                            .frame(width: 40, height: 40)
                            .background(Color.cyan.opacity(0.2))
                            .cornerRadius(8)
                            .rotationEffect(.degrees(iconRotation))
                    }

                    // Generator Info
                    VStack(alignment: .leading, spacing: 4) {
                        // Generator Name
                        Text(generator.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        // Level and Production Stats
                        HStack(spacing: 4) {
                            Text("Lv.\(generator.level)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if generator.level > 0 {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("\(generator.currentProductionPerSecond.formattedCredits)/s")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                Spacer()

                // Right: Level Up Button
                levelUpButton
            }

            // Progress bar (shows when generator is unlocked)
            if generator.level > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)

                        // Progress fill
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressToNextLevel, height: 4)
                            .animation(.easeOut(duration: 0.3), value: progressToNextLevel)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .celebration(isTriggered: $celebrationTriggered, color: .cyan)
        .scaleEffect(celebrationTriggered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: celebrationTriggered)
        .onAppear {
            startAnimations()
        }
        .onChange(of: isAffordable) { oldValue, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }

    // MARK: - Subviews

    /// Button to unlock or upgrade the generator
    private var levelUpButton: some View {
        Button(action: {
            viewModel.levelUp(generatorID: generator.id)
            triggerCelebration()
        }) {
            VStack(spacing: 2) {
                Text(generator.level == 0 ? "UNLOCK" : "UPGRADE")
                    .font(.caption.bold())
                Text(generator.nextLevelCost.formattedCredits)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isAffordable
                    ? LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [.gray, .gray],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            )
            .cornerRadius(8)
            .shadow(color: isAffordable ? .cyan.opacity(0.5) : .clear, radius: isPulsing ? 8 : 0)
        }
        .disabled(!isAffordable)
    }

    // MARK: - Helpers

    private func startAnimations() {
        // Rotate icon for active generators
        if generator.level > 0 {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                iconRotation = 360
            }
        }

        // Start pulse animation if affordable
        if isAffordable {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }

    private func triggerCelebration() {
        celebrationTriggered = true
    }
}

// MARK: - Preview

#Preview {
    let viewModel = GameViewModel()
    return GeneratorRowView(
        generator: Generator(
            name: "Mining Probe",
            level: 1,
            baseCost: 10,
            baseProduction: 1,
            iconName: "antenna.radiowaves.left.and.right"
        ),
        viewModel: viewModel
    )
    .padding()
    .background(Color.black)
}
