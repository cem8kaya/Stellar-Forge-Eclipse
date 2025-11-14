import SwiftUI

/// Main game view that displays the header and list of generators
struct GameView: View {
    // MARK: - State

    @StateObject private var viewModel = GameViewModel()
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            headerView

            // Tap Button
            TapButton(viewModel: viewModel)
                .frame(height: 280)
                .background(Color.black)

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

                            // Click Upgrades List
                            ForEach(viewModel.clickUpgrades) { upgrade in
                                ClickUpgradeRowView(upgrade: upgrade, viewModel: viewModel)
                                    .padding(.horizontal)
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

                        // Generators List
                        ForEach(viewModel.generators) { generator in
                            GeneratorRowView(generator: generator, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .padding(.bottom)
            }
        }
        .background(Color.black)
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
        }
    }

    // MARK: - Subviews

    /// Header displaying app title, credits, and production rate
    private var headerView: some View {
        VStack(spacing: 12) {
            // Title with space theme icon and prestige button
            HStack {
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

            // Credits display
            VStack(spacing: 4) {
                Text("Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(viewModel.credits.formattedCredits)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            // Production per second
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                Text("\(viewModel.totalCreditsPerSecond.formattedCredits) credits/sec")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

            // Prestige multiplier (shows if player has any shards)
            if viewModel.stellarShards > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "diamond.fill")
                        .foregroundColor(.cyan)
                    Text("\(viewModel.stellarShards) Stellar Shards")
                        .font(.caption)
                        .foregroundColor(.cyan)
                    Text("•")
                        .foregroundColor(.secondary)
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("\(viewModel.prestigeMultiplier, specifier: "%.1f")x multiplier")
                        .font(.caption)
                        .foregroundColor(.purple)
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
