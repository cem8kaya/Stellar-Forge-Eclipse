import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = Settings.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                settings.themeSelection.backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Audio & Haptics
                        SettingsSection(title: "Audio & Haptics", icon: "speaker.wave.2.fill") {
                            SettingsToggle(
                                title: "Haptic Feedback",
                                subtitle: "Feel vibrations when tapping and purchasing",
                                icon: "iphone.radiowaves.left.and.right",
                                isOn: $settings.hapticFeedbackEnabled
                            )

                            SettingsToggle(
                                title: "Sound Effects",
                                subtitle: "Play sounds for actions and events",
                                icon: "speaker.wave.2.circle.fill",
                                isOn: $settings.soundEffectsEnabled
                            )

                            SettingsToggle(
                                title: "Music",
                                subtitle: "Background music while playing",
                                icon: "music.note",
                                isOn: $settings.musicEnabled
                            )
                        }

                        // MARK: - Display Settings
                        SettingsSection(title: "Display", icon: "eye.fill") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "textformat.123")
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Notation Style")
                                            .font(.headline)
                                        Text("How numbers are displayed")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }

                                Picker("Notation Style", selection: $settings.notationStyle) {
                                    ForEach(Settings.NotationStyle.allCases, id: \.self) { style in
                                        VStack(alignment: .leading) {
                                            Text(style.displayName)
                                            Text(style.example)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .tag(style)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.leading, 32)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Theme")
                                            .font(.headline)
                                        Text("Choose your visual style")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Settings.Theme.allCases, id: \.self) { theme in
                                            ThemePreviewCard(
                                                theme: theme,
                                                isSelected: settings.themeSelection == theme
                                            )
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3)) {
                                                    settings.themeSelection = theme
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                                .padding(.leading, 28)
                            }
                        }

                        // MARK: - Gameplay Settings
                        SettingsSection(title: "Gameplay", icon: "gamecontroller.fill") {
                            SettingsToggle(
                                title: "Confirm Purchases",
                                subtitle: "Ask for confirmation before buying",
                                icon: "checkmark.shield.fill",
                                isOn: $settings.confirmPurchases
                            )

                            SettingsToggle(
                                title: "Auto-Buy",
                                subtitle: "Automatically purchase affordable generators",
                                icon: "bolt.fill",
                                isOn: $settings.autoBuyEnabled
                            )
                        }

                        // MARK: - Notifications
                        SettingsSection(title: "Notifications", icon: "bell.fill") {
                            SettingsToggle(
                                title: "Affordability Alerts",
                                subtitle: "Get notified when you can afford new items",
                                icon: "dollarsign.circle.fill",
                                isOn: $settings.affordabilityNotificationsEnabled
                            )

                            SettingsToggle(
                                title: "Achievement Alerts",
                                subtitle: "Get notified when unlocking achievements",
                                icon: "star.circle.fill",
                                isOn: $settings.achievementNotificationsEnabled
                            )
                        }

                        // MARK: - About Section
                        SettingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Space Mining Empire")
                                        .font(.headline)
                                    Spacer()
                                    Text("v1.0")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Button(action: {
                                    settings.showTutorial = true
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "questionmark.circle.fill")
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        Text("Show Tutorial Again")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Settings Section Component
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    @ObservedObject var settings = Settings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title3)

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }

            VStack(spacing: 16) {
                content
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
    }
}

// MARK: - Settings Toggle Component
struct SettingsToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    @ObservedObject var settings = Settings.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: [settings.themeSelection.primaryColor, settings.themeSelection.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(settings.themeSelection.primaryColor)
        }
    }
}

// MARK: - Theme Preview Card
struct ThemePreviewCard: View {
    let theme: Settings.Theme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)
                    .frame(width: 80, height: 60)

                VStack(spacing: 4) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 20, height: 20)

                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.primaryColor.opacity(0.6))
                            .frame(width: 16, height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.secondaryColor.opacity(0.6))
                            .frame(width: 16, height: 4)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? theme.primaryColor : Color.clear,
                        lineWidth: 3
                    )
            )

            Text(theme.displayName)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? theme.primaryColor : .secondary)
        }
    }
}

#Preview {
    SettingsView()
}
