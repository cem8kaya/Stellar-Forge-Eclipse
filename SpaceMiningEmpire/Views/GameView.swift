import SwiftUI

/// Main game view that displays the header and list of generators
struct GameView: View {
    // MARK: - State

    @StateObject private var viewModel = GameViewModel()
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Body

    var body: some View {
        ZStack {
            // Animated starfield background
            StarfieldView()

            VStack(spacing: 0) {
                // Header Section
                headerView

                // Tap Button
                TapButton(viewModel: viewModel)
                    .frame(height: 280)

                // Scrollable Content (Click Upgrades & Generators)
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Click Multiplier Upgrades Section
                        if !viewModel.clickUpgrades.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                // Section Header
                                HStack {
                                    Image(systemName: "hand.tap.fill")
                                        .foregroundColor(.yellow)
                                    Text("Click Multipliers")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))

                                // Click Upgrades List
                                ForEach(Array(viewModel.clickUpgrades.enumerated()), id: \.element.id) { index, upgrade in
                                    ClickUpgradeRowView(upgrade: upgrade, viewModel: viewModel)
                                        .padding(.horizontal)
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .leading).combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.clickUpgrades.count)
                                }
                            }
                            .padding(.top)
                        }

                        // Generators Section
                        VStack(alignment: .leading, spacing: 12) {
                            // Section Header
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.cyan)
                                Text("Generators")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))

                            // Generators List
                            ForEach(Array(viewModel.generators.enumerated()), id: \.element.id) { index, generator in
                                GeneratorRowView(generator: generator, viewModel: viewModel)
                                    .padding(.horizontal)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.generators.count)
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.bottom)
                }
            }
        }
        .foregroundColor(.white)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Save game when app goes to background or becomes inactive
            if newPhase == .background || newPhase == .inactive {
                viewModel.saveGame()
            }
        }
        .sheet(isPresented: $viewModel.isShowingOfflineModal) {
            OfflineEarningsView(earnings: viewModel.offlineEarnings) {
                viewModel.isShowingOfflineModal = false
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingPrestigeModal) {
            PrestigeView(
                currentShards: viewModel.stellarShards,
                potentialShards: viewModel.potentialStellarShards,
                currentMultiplier: viewModel.prestigeMultiplier,
                newMultiplier: viewModel.prestigeManager.prestigeMultiplier + Double(viewModel.potentialStellarShards) * 0.1,
                onPrestige: {
                    viewModel.prestige()
                    viewModel.isShowingPrestigeModal = false
                },
                onDismiss: {
                    viewModel.isShowingPrestigeModal = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingAchievementsModal) {
            AchievementsView(
                viewModel: viewModel,
                onDismiss: {
                    viewModel.isShowingAchievementsModal = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.isShowingStatsModal) {
            StatsView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subviews

    /// Header displaying app title, credits, and production rate
    private var headerView: some View {
        VStack(spacing: 12) {
            // Title with space theme icon and action buttons
            HStack(spacing: 12) {
                // Statistics button
                Button(action: {
                    viewModel.isShowingStatsModal = true
                }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                // Achievements button
                Button(action: {
                    viewModel.isShowingAchievementsModal = true
                }) {
                    ZStack {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)

                        // Badge showing unlocked count
                        if viewModel.achievementManager.unlockedCount > 0 {
                            Text("\(viewModel.achievementManager.unlockedCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.red))
                                .offset(x: 12, y: -10)
                        }
                    }
                }

                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Space Mining Empire")
                    .font(.title.bold())
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)

                // Prestige button (shows when player can prestige)
                if viewModel.canPrestige {
                    Button(action: {
                        viewModel.isShowingPrestigeModal = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text("Ascend")
                        }
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .purple.opacity(0.5), radius: 8)
                    }
                }
            }

            // Credits display with animated counter
            VStack(spacing: 4) {
                Text("Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)

                NumberCounterView(
                    value: viewModel.credits,
                    font: .system(size: 42, weight: .bold, design: .rounded),
                    foregroundColor: .white
                )
            }

            // Production per second
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                Text("\(viewModel.totalCreditsPerSecond.formattedCredits) credits/sec")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

            // Multipliers (shows if player has any bonuses)
            if viewModel.stellarShards > 0 || viewModel.achievementManager.unlockedCount > 0 {
                HStack(spacing: 4) {
                    // Prestige multiplier
                    if viewModel.stellarShards > 0 {
                        Image(systemName: "diamond.fill")
                            .foregroundColor(.cyan)
                        Text("\(viewModel.stellarShards) Shards")
                            .font(.caption)
                            .foregroundColor(.cyan)
                        Text("•")
                            .foregroundColor(.secondary)
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("\(viewModel.prestigeMultiplier, specifier: "%.1f")x")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }

                    // Achievement multiplier
                    if viewModel.achievementManager.unlockedCount > 0 {
                        if viewModel.stellarShards > 0 {
                            Text("•")
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("\(viewModel.achievementManager.unlockedCount) Achievements")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("•")
                            .foregroundColor(.secondary)
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(viewModel.achievementMultiplier, specifier: "%.2f")x")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Preview

#Preview {
    GameView()
}
