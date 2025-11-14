import SwiftUI

/// Celebration effect that triggers when purchasing/upgrading
struct PurchaseCelebrationView: View {
    // MARK: - Properties

    @Binding var isActive: Bool
    let color: Color

    @State private var particles: [ConfettiParticle] = []
    @State private var glowOpacity: Double = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // Glow effect
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 3)
                .shadow(color: color, radius: glowOpacity * 20)
                .opacity(glowOpacity)

            // Confetti particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(
                        x: cos(particle.angle) * particle.distance,
                        y: sin(particle.angle) * particle.distance - particle.gravity
                    )
                    .opacity(particle.opacity)
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                triggerCelebration()
            }
        }
    }

    // MARK: - Helpers

    private func triggerCelebration() {
        // Create confetti particles
        particles = (0..<20).map { i in
            ConfettiParticle(
                angle: Double(i) * (2 * .pi / 20),
                color: [.cyan, .blue, .purple, .yellow, .green].randomElement() ?? .cyan,
                size: CGFloat.random(in: 4...8)
            )
        }

        // Animate glow
        withAnimation(.easeOut(duration: 0.3)) {
            glowOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            glowOpacity = 0
        }

        // Animate particles
        for i in particles.indices {
            withAnimation(.easeOut(duration: 0.8)) {
                particles[i].distance = 60
                particles[i].gravity = CGFloat.random(in: 30...60)
                particles[i].opacity = 0
            }
        }

        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isActive = false
            particles = []
        }
    }
}

// MARK: - Supporting Types

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let color: Color
    let size: CGFloat
    var distance: CGFloat = 0
    var gravity: CGFloat = 0
    var opacity: Double = 1.0
}

/// View modifier to add celebration effect
struct CelebrationModifier: ViewModifier {
    @Binding var isTriggered: Bool
    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay {
                PurchaseCelebrationView(isActive: $isTriggered, color: color)
                    .allowsHitTesting(false)
            }
    }
}

extension View {
    /// Add celebration effect overlay to any view
    func celebration(isTriggered: Binding<Bool>, color: Color = .cyan) -> some View {
        modifier(CelebrationModifier(isTriggered: isTriggered, color: color))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var isActive = false

        var body: some View {
            VStack(spacing: 40) {
                Button("Trigger Celebration") {
                    isActive = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .celebration(isTriggered: $isActive)

                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 100)
                    .overlay {
                        Text("Generator Row")
                            .foregroundColor(.white)
                    }
                    .celebration(isTriggered: $isActive, color: .cyan)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }

    return PreviewWrapper()
}
