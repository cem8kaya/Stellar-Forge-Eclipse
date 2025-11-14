import SwiftUI

/// Animated starfield background with parallax scrolling effect
struct StarfieldView: View {
    // MARK: - Properties

    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0
    @State private var offset3: CGFloat = 0

    private let starCount = 50  // Reduced for better performance
    private let stars: [Star]

    // MARK: - Initialization

    init() {
        // Generate random stars with different sizes and speeds
        self.stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...1.0),
                layer: Int.random(in: 1...3)
            )
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Star layers with parallax effect
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .opacity(star.opacity)
                        .position(
                            x: star.x * geometry.size.width,
                            y: calculateYPosition(for: star, in: geometry.size)
                        )
                        .blur(radius: star.layer == 3 ? 0.5 : 0)
                }
            }
            .onAppear {
                startAnimation()
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private func calculateYPosition(for star: Star, in size: CGSize) -> CGFloat {
        let baseY = star.y * size.height

        // Apply parallax offset based on layer
        let offset: CGFloat
        switch star.layer {
        case 1:
            offset = offset1
        case 2:
            offset = offset2
        default:
            offset = offset3
        }

        // Wrap around when star goes off screen
        let adjustedY = (baseY + offset).truncatingRemainder(dividingBy: size.height + 50)
        return adjustedY < 0 ? adjustedY + size.height + 50 : adjustedY
    }

    private func startAnimation() {
        // Layer 1: Slowest (background stars)
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
            offset1 = 800
        }

        // Layer 2: Medium speed
        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
            offset2 = 800
        }

        // Layer 3: Fastest (foreground stars)
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            offset3 = 800
        }
    }
}

// MARK: - Supporting Types

struct Star: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let layer: Int
}

// MARK: - Preview

#Preview {
    StarfieldView()
}
