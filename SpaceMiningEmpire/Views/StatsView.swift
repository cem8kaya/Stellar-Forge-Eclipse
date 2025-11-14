import SwiftUI
import Charts

/// Comprehensive statistics view for Space Mining Empire
struct StatsView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Lifetime Stats
                        statsSection(title: "Lifetime Statistics") {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatCardView(
                                    iconName: "chart.line.uptrend.xyaxis",
                                    label: "Lifetime Credits",
                                    value: viewModel.totalCreditsEarned.formattedCredits,
                                    gradientColors: [.blue, .cyan]
                                )

                                StatCardView(
                                    iconName: "hand.tap.fill",
                                    label: "Total Taps",
                                    value: "\(viewModel.totalTaps.formatted())",
                                    gradientColors: [.purple, .pink]
                                )

                                StatCardView(
                                    iconName: "clock.fill",
                                    label: "Time Played",
                                    value: formatTime(viewModel.totalTimePlayed),
                                    gradientColors: [.orange, .red]
                                )

                                StatCardView(
                                    iconName: "cart.fill",
                                    label: "Upgrades Purchased",
                                    value: "\(viewModel.totalUpgradesPurchased)",
                                    gradientColors: [.green, .mint]
                                )
                            }
                        }

                        // MARK: - Production Stats
                        statsSection(title: "Production Statistics") {
                            VStack(spacing: 12) {
                                StatCardView(
                                    iconName: "bolt.fill",
                                    label: "Current CPS",
                                    value: "\(viewModel.totalCreditsPerSecond.formattedCredits)/s",
                                    gradientColors: [.yellow, .orange]
                                )

                                StatCardView(
                                    iconName: "chart.bar.fill",
                                    label: "Peak CPS",
                                    value: "\(viewModel.peakCreditsPerSecond.formattedCredits)/s",
                                    gradientColors: [.red, .pink]
                                )

                                if let mostValuable = viewModel.mostValuableGenerator {
                                    StatCardView(
                                        iconName: mostValuable.iconName,
                                        label: "Most Valuable Generator",
                                        value: "\(mostValuable.name) (Lv.\(mostValuable.level))",
                                        gradientColors: [.indigo, .purple]
                                    )
                                }
                            }
                        }

                        // MARK: - Prestige & Achievements
                        statsSection(title: "Prestige & Achievements") {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatCardView(
                                    iconName: "star.fill",
                                    label: "Prestige Count",
                                    value: "\(viewModel.prestigeManager.lifetimePrestigeCount)",
                                    gradientColors: [.yellow, .orange]
                                )

                                StatCardView(
                                    iconName: "sparkles",
                                    label: "Prestige Multiplier",
                                    value: String(format: "%.1fx", viewModel.prestigeMultiplier),
                                    gradientColors: [.cyan, .blue]
                                )

                                StatCardView(
                                    iconName: "trophy.fill",
                                    label: "Achievement Progress",
                                    value: String(format: "%.0f%%", viewModel.achievementCompletionPercentage),
                                    gradientColors: [.purple, .pink]
                                )

                                StatCardView(
                                    iconName: "flame.fill",
                                    label: "Achievement Multiplier",
                                    value: String(format: "%.2fx", viewModel.achievementMultiplier),
                                    gradientColors: [.orange, .red]
                                )
                            }
                        }

                        // MARK: - Session Stats
                        statsSection(title: "Current Session") {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                StatCardView(
                                    iconName: "timer",
                                    label: "Session Time",
                                    value: formatTime(viewModel.sessionTimePlayed),
                                    gradientColors: [.green, .mint]
                                )

                                StatCardView(
                                    iconName: "hand.tap.fill",
                                    label: "Session Taps",
                                    value: "\(viewModel.sessionTaps)",
                                    gradientColors: [.blue, .purple]
                                )

                                StatCardView(
                                    iconName: "chart.line.uptrend.xyaxis",
                                    label: "Session Credits",
                                    value: viewModel.sessionCreditsEarned.formattedCredits,
                                    gradientColors: [.cyan, .blue]
                                )

                                StatCardView(
                                    iconName: "percent",
                                    label: "Total Multiplier",
                                    value: String(format: "%.2fx", viewModel.totalMultiplier),
                                    gradientColors: [.pink, .red]
                                )
                            }
                        }

                        // MARK: - Production Over Time Chart
                        if !viewModel.productionHistory.isEmpty {
                            statsSection(title: "Production Over Time") {
                                VStack(alignment: .leading, spacing: 8) {
                                    Chart {
                                        ForEach(viewModel.productionHistory) { dataPoint in
                                            LineMark(
                                                x: .value("Time", dataPoint.timestamp),
                                                y: .value("CPS", dataPoint.creditsPerSecond)
                                            )
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .cyan],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .interpolationMethod(.catmullRom)

                                            AreaMark(
                                                x: .value("Time", dataPoint.timestamp),
                                                y: .value("CPS", dataPoint.creditsPerSecond)
                                            )
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue.opacity(0.3), .cyan.opacity(0.1)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .interpolationMethod(.catmullRom)
                                        }
                                    }
                                    .frame(height: 200)
                                    .chartXAxis {
                                        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                                                .foregroundStyle(.gray.opacity(0.3))
                                            AxisValueLabel()
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks { value in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                                                .foregroundStyle(.gray.opacity(0.3))
                                            AxisValueLabel()
                                                .foregroundStyle(.gray)
                                        }
                                    }

                                    Text("Credits per second tracked over the last hour")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.top, 4)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                        }

                        // MARK: - Generator Production Breakdown (Pie Chart)
                        statsSection(title: "Production Breakdown") {
                            VStack(alignment: .leading, spacing: 8) {
                                Chart {
                                    ForEach(viewModel.generators.filter { $0.isUnlocked }) { generator in
                                        SectorMark(
                                            angle: .value("Production", generator.currentProductionPerSecond),
                                            innerRadius: .ratio(0.5),
                                            angularInset: 2
                                        )
                                        .cornerRadius(4)
                                        .foregroundStyle(by: .value("Generator", generator.name))
                                    }
                                }
                                .frame(height: 200)
                                .chartLegend(position: .bottom, spacing: 8)

                                Text("Production contribution by each generator")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }

                        // MARK: - Daily Activity Heatmap
                        if !viewModel.dailyActivity.isEmpty {
                            statsSection(title: "Daily Activity (Last 30 Days)") {
                                VStack(alignment: .leading, spacing: 8) {
                                    Chart(viewModel.dailyActivity) { activity in
                                        BarMark(
                                            x: .value("Date", activity.date, unit: .day),
                                            y: .value("Taps", activity.tapCount)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.purple, .pink],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                    }
                                    .frame(height: 150)
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                                                .foregroundStyle(.gray.opacity(0.3))
                                            AxisValueLabel(format: .dateTime.month().day())
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks { _ in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                                                .foregroundStyle(.gray.opacity(0.3))
                                            AxisValueLabel()
                                                .foregroundStyle(.gray)
                                        }
                                    }

                                    Text("Your daily tapping activity")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.top, 4)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                        }

                        // MARK: - Generator Efficiency Ratings
                        statsSection(title: "Generator Efficiency") {
                            VStack(spacing: 12) {
                                ForEach(viewModel.generators.filter { $0.isUnlocked }) { generator in
                                    HStack {
                                        Image(systemName: generator.iconName)
                                            .font(.title3)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 40)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(generator.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)

                                            HStack(spacing: 16) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Level")
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                    Text("\(generator.level)")
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                }

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Production")
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                    Text("\(generator.currentProductionPerSecond.formattedCredits)/s")
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                }

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Next Cost")
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                    Text(generator.nextLevelCost.formattedCredits)
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func statsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .gray],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            content()
        }
    }

    // MARK: - Helper Functions

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60

        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    StatsView(viewModel: GameViewModel())
}
