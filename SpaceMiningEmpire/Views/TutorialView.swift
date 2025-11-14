import SwiftUI

struct TutorialView: View {
    let onDismiss: () -> Void
    @State private var currentPage = 0
    @ObservedObject var settings = Settings.shared

    let tutorialPages: [TutorialPage] = [
        TutorialPage(
            icon: "hand.tap.fill",
            color: .cyan,
            title: "Welcome to Space Mining Empire!",
            description: "Build your mining empire across the galaxy by tapping, upgrading, and automating your production.",
            tips: [
                "Tap the crystal to earn credits manually",
                "Use credits to unlock and upgrade generators",
                "Watch your empire grow exponentially!"
            ]
        ),
        TutorialPage(
            icon: "gear",
            color: .green,
            title: "Generators",
            description: "Generators produce credits automatically every second, even when you're not playing.",
            tips: [
                "Start with the Mining Probe, then unlock more powerful generators",
                "Each generator level increases its production",
                "Use x10, x100, or Max buttons for bulk purchases",
                "Enable Auto-buy to automatically purchase upgrades"
            ]
        ),
        TutorialPage(
            icon: "hand.point.up.fill",
            color: .yellow,
            title: "Click Multipliers",
            description: "Click Multipliers increase how many credits you earn per tap.",
            tips: [
                "Each multiplier upgrade adds to your tap power",
                "Combine with prestige bonuses for massive taps",
                "Perfect for active play sessions"
            ]
        ),
        TutorialPage(
            icon: "sparkles",
            color: .purple,
            title: "Prestige System",
            description: "When you've earned 1M+ total credits, you can Ascend to earn Stellar Shards.",
            tips: [
                "Stellar Shards provide permanent multipliers",
                "Each Shard gives +10% to ALL production",
                "Prestiging resets generators but keeps achievements",
                "The 'Ascend' button appears when ready"
            ]
        ),
        TutorialPage(
            icon: "trophy.fill",
            color: .orange,
            title: "Achievements",
            description: "Complete achievements to earn permanent multiplier bonuses.",
            tips: [
                "24 achievements to unlock across 8 categories",
                "Each achievement adds to your global multiplier",
                "Achievements persist through prestige",
                "Check the trophy icon to track progress"
            ]
        ),
        TutorialPage(
            icon: "bolt.fill",
            color: .green,
            title: "Quality of Life Features",
            description: "Take advantage of helpful features to streamline your gameplay.",
            tips: [
                "Use x10/x100/Max buttons for bulk purchases",
                "Enable Auto-buy for hands-free progress",
                "Adjust settings like haptics and notation style",
                "View detailed statistics and production charts"
            ]
        ),
        TutorialPage(
            icon: "chart.bar.fill",
            color: .cyan,
            title: "Track Your Progress",
            description: "Monitor your empire's growth with comprehensive statistics.",
            tips: [
                "View production history over time",
                "Check generator efficiency ratings",
                "Track daily activity and trends",
                "See your best session and lifetime records"
            ]
        ),
        TutorialPage(
            icon: "moon.stars.fill",
            color: .blue,
            title: "Offline Earnings",
            description: "Your generators keep working while you're away!",
            tips: [
                "Earn up to 24 hours of offline production",
                "Prestige and achievement multipliers still apply",
                "Perfect for casual play sessions",
                "Come back to massive credit boosts!"
            ]
        ),
        TutorialPage(
            icon: "star.fill",
            color: .yellow,
            title: "Ready to Begin!",
            description: "You're all set to build your space mining empire. Good luck!",
            tips: [
                "Start by tapping to earn initial credits",
                "Unlock your first generators",
                "Experiment with different strategies",
                "Access this tutorial anytime from the ? button"
            ]
        )
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                settings.themeSelection.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<tutorialPages.count, id: \.self) { index in
                            TutorialPageView(page: tutorialPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))

                    // Bottom navigation
                    HStack(spacing: 20) {
                        // Previous button
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                }
                                .font(.headline)
                                .foregroundColor(settings.themeSelection.primaryColor)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(settings.themeSelection.primaryColor, lineWidth: 2)
                                )
                            }
                        }

                        Spacer()

                        // Page indicator
                        Text("\(currentPage + 1) / \(tutorialPages.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        // Next/Done button
                        Button(action: {
                            if currentPage < tutorialPages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                onDismiss()
                            }
                        }) {
                            HStack {
                                Text(currentPage == tutorialPages.count - 1 ? "Get Started" : "Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.primary.opacity(0.05))
                }
            }
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        onDismiss()
                    }
                    .foregroundColor(settings.themeSelection.primaryColor)
                }
            }
        }
    }
}

// MARK: - Tutorial Page Model
struct TutorialPage {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let tips: [String]
}

// MARK: - Tutorial Page View
struct TutorialPageView: View {
    let page: TutorialPage
    @ObservedObject var settings = Settings.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [page.color.opacity(0.3), page.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Image(systemName: page.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [page.color, page.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: page.color.opacity(0.5), radius: 10)
                }
                .padding(.top, 40)

                // Title
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Tips section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Tips")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(page.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(settings.themeSelection.primaryColor)
                                    .font(.title3)

                                Text(tip)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primary.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                settings.themeSelection.primaryColor.opacity(0.3),
                                                settings.themeSelection.secondaryColor.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer(minLength: 20)
            }
        }
    }
}

#Preview {
    TutorialView(onDismiss: {})
}
