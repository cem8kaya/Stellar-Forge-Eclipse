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
    }

    // MARK: - Subviews

    /// Header displaying app title, credits, and production rate
    private var headerView: some View {
        VStack(spacing: 12) {
            // Title with space theme icon
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Space Mining Empire")
                    .font(.title.bold())
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
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
