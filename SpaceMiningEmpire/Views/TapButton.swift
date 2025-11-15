import SwiftUI

/// A particle that animates during a tap burst effect
struct TapParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let speed: Double
}

/// Large circular tap button with scale animation and particle burst effects
struct TapButton: View {
    // MARK: - Properties

    @ObservedObject var viewModel: GameViewModel

    // MARK: - State

    @State private var isPressed = false
    @State private var particles: [TapParticle] = []
    @State private var showCreditsEarned = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Particle burst effect
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: cos(particle.angle) * particle.speed * 50,
                        y: sin(particle.angle) * particle.speed * 50
                    )
                    .opacity(1.0 - particle.speed)
                    .animation(.easeOut(duration: 0.6), value: particle.speed)
            }

            // Main tap button
            VStack(spacing: 16) {
                // Tap button circle
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.clear]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 90
                            )
                        )
                        .frame(width: 180, height: 180)

                    // Main button
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.yellow.opacity(0.5), radius: 20, x: 0, y: 0)

                    // Icon
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .scaleEffect(isPressed ? 0.85 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)

                // Credits per tap display
                VStack(spacing: 4) {
                    Text("Credits per tap")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("+\(viewModel.creditsPerTap.formattedCredits)")
                        .font(.title3.bold())
                        .foregroundColor(.yellow)
                }

                // Floating credits earned indicator
                if showCreditsEarned {
                    Text("+\(viewModel.creditsPerTap.formattedCredits)")
                        .font(.title2.bold())
                        .foregroundColor(.yellow)
                        .offset(y: -50)
                        .opacity(0)
                        .animation(.easeOut(duration: 0.8), value: showCreditsEarned)
                }
            }
        }
        .onTapGesture {
            handleTap()
        }
    }

    // MARK: - Methods

    /// Handles tap gesture with animation and particle effects
    private func handleTap() {
        // Scale animation
        isPressed = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPressed = false
        }

        // Create particle burst
        createParticleBurst()

        // Show credits earned
        showCreditsAnimation()

        // Call view model to add credits
        viewModel.handleTap()
    }

    /// Creates a burst of particles radiating outward
    private func createParticleBurst() {
        // Clear old particles
        particles.removeAll()

        // Create 12 particles in a circle
        for i in 0..<12 {
            let angle = Double(i) * (2 * .pi / 12)
            let particle = TapParticle(angle: angle, speed: 0.0)
            particles.append(particle)
        }

        // Animate particles outward
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            for i in 0..<particles.count {
                particles[i] = TapParticle(angle: particles[i].angle, speed: 1.0)
            }
        }

        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            particles.removeAll()
        }
    }

    /// Shows floating credits earned animation
    private func showCreditsAnimation() {
        showCreditsEarned = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            showCreditsEarned = false
        }
    }
}

// MARK: - Preview

#Preview {
    let viewModel = GameViewModel()
    TapButton(viewModel: viewModel)
        .background(Color.black)
}
