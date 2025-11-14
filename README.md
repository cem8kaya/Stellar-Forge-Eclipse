# Space Mining Empire

**Stellar-Forge-Eclipse** is an engaging idle clicker game built with SwiftUI for iOS. Manage your space mining empire, upgrade your generators, unlock achievements, and prestige to earn powerful multipliers!

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Game Mechanics](#game-mechanics)
- [Building & Running](#building--running)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [License](#license)

---

## Overview

**Space Mining Empire** is a space-themed incremental clicker game where you build and manage a mining empire across the cosmos. Start with a simple Mining Probe and work your way up to commanding Stellar Forges that harness the power of stars themselves!

### Game Objective

- **Earn Credits**: Tap the mining button or let your generators produce credits automatically
- **Purchase Generators**: Unlock and upgrade 6 different generator types, each more powerful than the last
- **Boost Your Power**: Purchase click multiplier upgrades to increase tap earnings
- **Unlock Achievements**: Complete 25+ achievements to earn permanent production bonuses
- **Prestige System**: Reset your progress to earn Stellar Shards for massive multipliers
- **Track Progress**: View comprehensive statistics and production history

---

## Features

### Core Gameplay

- **Manual Tapping**: Click to earn credits manually with satisfying haptic feedback
- **6 Generator Types**:
  - Mining Probe (Base: 1 credit/sec)
  - Asteroid Harvester (Base: 10 credits/sec)
  - Quantum Drill (Base: 50 credits/sec)
  - Fusion Reactor (Base: 200 credits/sec)
  - Antimatter Generator (Base: 1,000 credits/sec)
  - Stellar Forge (Base: 5,000 credits/sec)

- **5 Click Upgrade Types**:
  - Titanium Finger (+1 per tap)
  - Laser Pointer (+5 per tap)
  - Quantum Clicker (+25 per tap)
  - Neural Amplifier (+100 per tap)
  - Reality Bender (+500 per tap)

### Progression Systems

- **Prestige System (Stellar Shards)**:
  - Requires 1M+ total credits earned
  - Formula: `floor(sqrt(totalCreditsEarned / 1,000,000))`
  - Each shard grants +10% production multiplier
  - Resets generators and upgrades but keeps achievements

- **Achievement System**:
  - 25+ unique achievements to unlock
  - Achievement types:
    - Credit milestones
    - Generator upgrades
    - Tap counts
    - Prestige achievements
    - Production rate milestones
  - Each achievement grants a permanent multiplier bonus

- **Offline Earnings**:
  - Earn credits while the app is closed (up to 24 hours)
  - Calculates production based on your generator levels
  - Applies prestige and achievement multipliers

### Quality of Life Features

- **Auto-Buy System**:
  - Toggle auto-buy for individual generators
  - Automatically purchases upgrades when affordable
  - Configurable per-generator settings

- **Bulk Purchasing**:
  - Buy 1x, 10x, 25x, or MAX levels at once
  - Calculates optimal bulk purchase costs

- **Affordability Notifications**:
  - Visual indicators when you can afford upgrades
  - Badge system for available purchases

- **Tutorial System**:
  - Interactive onboarding for new players
  - Explains core mechanics and features
  - Can be revisited from settings

### Statistics & Analytics

- **Comprehensive Stats Screen**:
  - Total credits earned (lifetime)
  - Peak credits per second
  - Total time played
  - Session statistics
  - Total taps performed
  - Total upgrades purchased
  - Most valuable generator
  - Achievement completion percentage

- **Production History Chart**:
  - Tracks credits per second over time
  - Last 60 data points (1-hour history)
  - Updates every minute

- **Daily Activity Heatmap**:
  - Tracks daily engagement
  - Shows tap counts and credits earned per day
  - Last 30 days of activity

### Customization Settings

- **Display Options**:
  - Number notation styles (Abbreviated: 1.5K, Full: 1,500)
  - Multiple theme options (Dark, Light, Cosmic, Nebula)

- **Gameplay Settings**:
  - Haptic feedback toggle
  - Sound effects toggle (placeholder)
  - Music toggle (placeholder)
  - Confirm purchases option
  - Auto-buy global toggle
  - Affordability notifications
  - Achievement notifications

### Visual Polish

- **Animated Starfield Background**: Dynamic particle system
- **Smooth Transitions**: Spring animations throughout the UI
- **Number Counters**: Animated number displays for credits
- **Purchase Celebrations**: Visual feedback on purchases
- **Haptic Feedback**: Physical response to interactions (iOS)
- **Gradient Themes**: Beautiful color gradients matching space theme

---

## Game Mechanics

### Credit Production Formula

```swift
// Base production from all generators
baseProduction = sum(generator.baseProduction * generator.level)

// Apply multipliers
totalMultiplier = prestigeMultiplier * achievementMultiplier

// Final production per second
creditsPerSecond = baseProduction * totalMultiplier
```

### Prestige Multiplier

```swift
prestigeMultiplier = 1.0 + (stellarShards * 0.1)
// Example: 10 shards = 2.0x multiplier (100% bonus)
```

### Generator Cost Scaling

```swift
nextLevelCost = baseCost * pow(1.15, currentLevel)
// 15% cost increase per level
```

### Stellar Shards Calculation

```swift
stellarShards = floor(sqrt(totalCreditsEarned / 1_000_000))
// Example: 4M credits = 2 shards, 9M credits = 3 shards
```

### Offline Earnings

```swift
// Maximum offline time: 24 hours (86,400 seconds)
offlineEarnings = creditsPerSecond * min(timeSinceLastSave, 86400)
```

---

## Building & Running

### Prerequisites

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: iOS 16.0 or later
- **Swift**: 5.9 or later

### Important Note

This repository contains **source code only** and does **not include an Xcode project file** (`.xcodeproj`). You will need to create a new Xcode project to build and run the application.

### Setup Instructions

#### Option 1: Create New Xcode Project

1. **Open Xcode**
2. **Create a new project**:
   - Select **iOS** → **App**
   - Product Name: `SpaceMiningEmpire` (or your preferred name)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Save the project

3. **Add source files**:
   - Delete the default `ContentView.swift` and app file
   - Drag the entire `SpaceMiningEmpire` folder into your Xcode project
   - Select **Copy items if needed**
   - Ensure all `.swift` files are added to your target

4. **Configure the project**:
   - Set the bundle identifier
   - Configure signing & capabilities
   - Set deployment target to iOS 16.0+

5. **Build and run**:
   - Select a simulator or device
   - Press `Cmd + R` to build and run

#### Option 2: Use Swift Package Manager (Advanced)

You can convert this to a Swift Package by creating a `Package.swift` file:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SpaceMiningEmpire",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "SpaceMiningEmpire",
            targets: ["SpaceMiningEmpire"]
        ),
    ],
    targets: [
        .target(
            name: "SpaceMiningEmpire",
            path: "SpaceMiningEmpire"
        ),
    ]
)
```

### Building for iPhone Device

1. **Connect your iPhone** via USB or use wireless debugging
2. **Configure Signing**:
   - In Xcode, select your project
   - Go to **Signing & Capabilities**
   - Select your development team
   - Xcode will automatically generate a provisioning profile

3. **Trust Developer on Device**:
   - On iPhone: **Settings** → **General** → **VPN & Device Management**
   - Trust your developer certificate

4. **Run on Device**:
   - Select your iPhone from the device dropdown
   - Press `Cmd + R` to build and install

### Running in Simulator

1. **Open Xcode**
2. **Select any iOS Simulator** (iPhone 14, 15, etc.)
3. **Build and run** (`Cmd + R`)

**Note**: Haptic feedback will not work in the simulator (iOS device required).

---

## Project Structure

```
Stellar-Forge-Eclipse/
├── README.md                          # This file
├── LICENSE                            # MIT License
└── SpaceMiningEmpire/                 # Main application source
    ├── SpaceMiningEmpireApp.swift     # App entry point (@main)
    │
    ├── Models/                        # Data models and business logic
    │   ├── Achievement.swift          # Achievement data structure
    │   ├── AchievementManager.swift   # Achievement system manager (25+ achievements)
    │   ├── ClickUpgrade.swift         # Click multiplier upgrade model
    │   ├── Generator.swift            # Generator data structure
    │   ├── PrestigeManager.swift      # Prestige system and Stellar Shards
    │   └── Settings.swift             # User preferences and settings
    │
    ├── ViewModels/                    # MVVM ViewModel layer
    │   └── GameViewModel.swift        # Core game logic (967 lines)
    │       ├── Game state management
    │       ├── Production calculations
    │       ├── Persistence (UserDefaults)
    │       ├── Offline earnings
    │       ├── Achievement checking
    │       └── Statistics tracking
    │
    ├── Views/                         # SwiftUI view components
    │   ├── GameView.swift             # Main game screen
    │   ├── TapButton.swift            # Central tap button with animations
    │   ├── GeneratorRowView.swift     # Generator list item with buy options
    │   ├── ClickUpgradeRowView.swift  # Click upgrade list item
    │   ├── StatsView.swift            # Comprehensive statistics dashboard
    │   ├── SettingsView.swift         # Settings and preferences screen
    │   ├── AchievementsView.swift     # Achievement browser with progress
    │   ├── PrestigeView.swift         # Prestige confirmation modal
    │   ├── TutorialView.swift         # Interactive tutorial/onboarding
    │   ├── OfflineEarningsView.swift  # Offline earnings notification modal
    │   ├── StarfieldView.swift        # Animated background particle system
    │   ├── StatCardView.swift         # Reusable stat display card
    │   ├── NumberCounterView.swift    # Animated number counter
    │   └── PurchaseCelebrationView.swift # Purchase feedback animation
    │
    └── Utilities/                     # Helper utilities
        └── NumberFormatter+Extensions.swift # Credit number formatting (K, M, B, T)
```

### File Organization

- **23 Swift files** totaling approximately **4,780 lines of code**
- **Zero external dependencies** (uses only SwiftUI and Foundation)
- **MVVM architecture** with clear separation of concerns

---

## Architecture

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────────┐
│                         Views                            │
│  (SwiftUI Components - User Interface Layer)            │
│  • GameView, TapButton, GeneratorRowView, etc.          │
└────────────────────┬────────────────────────────────────┘
                     │ @StateObject / @ObservedObject
                     ↓
┌─────────────────────────────────────────────────────────┐
│                      ViewModel                           │
│              (GameViewModel - Business Logic)            │
│  • State management (@Published properties)             │
│  • Game logic (production, purchasing, prestige)        │
│  • Persistence (UserDefaults)                           │
│  • Calculations (offline earnings, costs, multipliers)  │
└────────────────────┬────────────────────────────────────┘
                     │ Uses
                     ↓
┌─────────────────────────────────────────────────────────┐
│                       Models                             │
│              (Data Structures & Managers)                │
│  • Generator, Achievement, ClickUpgrade                 │
│  • AchievementManager, PrestigeManager, Settings        │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Components

#### 1. Models Layer

**Purpose**: Define data structures and simple business rules

- **Generator**: Represents income-producing buildings
  - Properties: name, level, baseCost, baseProduction, iconName
  - Computed: nextLevelCost, currentProductionPerSecond

- **Achievement**: Unlockable goals with reward multipliers
  - Properties: title, description, requirementType, targetValue, rewardMultiplier
  - Types: credits, generators, taps, prestige, production milestones

- **ClickUpgrade**: Manual tap multiplier upgrades
  - Properties: name, level, baseCost, baseMultiplier
  - Computed: nextLevelCost, currentMultiplier

- **PrestigeManager**: Handles game resets and Stellar Shards
  - Tracks lifetime prestige count
  - Calculates shard rewards
  - Provides multiplier bonuses

- **AchievementManager**: Manages all achievements
  - Checks unlock conditions
  - Calculates total multiplier from achievements
  - Tracks unlock timestamps

- **Settings**: User preferences (Singleton pattern)
  - Display options (number format, themes)
  - Gameplay toggles (auto-buy, haptics)
  - Per-generator auto-buy configuration

#### 2. ViewModel Layer

**GameViewModel** (967 lines) - The heart of the application:

**State Management**:
- `@Published` properties for reactive UI updates
- ObservableObject conformance for SwiftUI binding

**Core Responsibilities**:
1. **Production Loop**:
   - Timer-based credit generation (1-second intervals)
   - Applies multipliers from prestige and achievements
   - Updates statistics (peak CPS, production history)

2. **Persistence**:
   - UserDefaults for save/load
   - JSON encoding for complex types
   - Auto-save on app backgrounding

3. **Offline Earnings**:
   - Calculates time since last save
   - Caps at 24 hours maximum
   - Displays modal on app launch

4. **Purchase Logic**:
   - Cost calculations with exponential scaling
   - Bulk purchase (1x, 10x, 25x, MAX)
   - Affordability tracking

5. **Prestige System**:
   - Calculates potential Stellar Shards
   - Resets game state
   - Preserves lifetime statistics

6. **Achievement Checking**:
   - Runs on every significant game event
   - Unlocks achievements automatically
   - Triggers notifications and haptics

7. **Statistics Tracking**:
   - Session metrics (time, credits, taps)
   - Production history (60 data points)
   - Daily activity heatmap (30 days)

#### 3. Views Layer

**SwiftUI Declarative UI**:

- **GameView**: Main container with header, tap button, and scrollable upgrades
- **Component Views**: Reusable UI elements (buttons, cards, rows)
- **Modal Views**: Sheets for prestige, achievements, stats, settings
- **Animation Views**: Starfield background, celebrations, transitions

**UI Patterns**:
- Reactive updates via Combine framework
- Environment and StateObject for dependency injection
- Sheet presentations for modals
- LazyVStack for performance with long lists

### Data Flow

```
User Interaction (Tap/Purchase)
        ↓
View calls ViewModel method
        ↓
ViewModel updates @Published state
        ↓
View automatically re-renders (Combine)
        ↓
ViewModel saves to UserDefaults
```

### Persistence Strategy

**UserDefaults** is used for all game data:

- **Advantages**:
  - Simple key-value storage
  - Automatic synchronization
  - No external dependencies
  - Perfect for small datasets

- **Saved Data**:
  - Credits, generators, upgrades (JSON encoded)
  - Prestige manager, achievement manager
  - Statistics (time played, peak CPS, etc.)
  - Production history, daily activity
  - Settings and preferences

- **Save Triggers**:
  - After every purchase or upgrade
  - When app enters background
  - After prestige
  - Periodically during time tracking (every minute)

### Performance Optimizations

1. **Timer Management**:
   - Single production timer for all generators
   - Weak self references to prevent retain cycles
   - Proper cleanup in deinit

2. **Lazy Loading**:
   - LazyVStack for generator/upgrade lists
   - Only renders visible items

3. **Efficient Calculations**:
   - Pre-computed properties where possible
   - Cached multiplier calculations
   - Minimal redundant operations

4. **Production History Cap**:
   - Limits to 60 data points (1 hour at 1-minute intervals)
   - Prevents unbounded memory growth

---

## Technologies Used

### Core Frameworks

- **SwiftUI**: Declarative UI framework for building native iOS interfaces
- **Combine**: Reactive programming for data binding and state management
- **Foundation**: Core Swift utilities and data structures
- **UIKit**: Haptic feedback via UIImpactFeedbackGenerator

### Swift Language Features

- **Codable**: JSON encoding/decoding for persistence
- **@Published**: Property wrapper for reactive state
- **@AppStorage**: Property wrapper for UserDefaults binding
- **Computed Properties**: Dynamic value calculations
- **Extensions**: Number formatting and utility methods
- **Enums**: Type-safe requirement types and settings

### iOS APIs

- **UserDefaults**: Persistent key-value storage
- **Timer.publish**: Periodic production updates
- **ScenePhase**: App lifecycle management for save triggers
- **HapticFeedback**: Physical feedback on interactions

### No External Dependencies

This project uses **zero third-party libraries or frameworks**. Everything is built with native Swift and SwiftUI APIs.

---

## Game Progression Guide

### Early Game (0 - 10K credits)

- Focus on manual tapping
- Purchase Mining Probes (first generator)
- Unlock Titanium Finger (first click upgrade)
- Aim for 10 Mining Probes before moving to next generator

### Mid Game (10K - 1M credits)

- Unlock Asteroid Harvesters and Quantum Drills
- Balance generator purchases for efficiency
- Invest in Laser Pointer and Quantum Clicker upgrades
- Start tracking production per second

### Late Game (1M+ credits)

- Unlock Fusion Reactors and Antimatter Generators
- First prestige opportunity at 1M total credits
- Farm Stellar Shards for multipliers
- Work towards Stellar Forge (most powerful generator)

### End Game (Multiple Prestiges)

- Optimize prestige timing for maximum shards
- Unlock all achievements for multiplier bonuses
- Max out all generators with prestige multipliers
- Compete for highest credits per second

---

## Statistics & Tracking

### Available Metrics

- **Total Credits Earned**: Lifetime across all prestiges
- **Current Credits**: Current balance
- **Credits Per Second**: Real-time production rate
- **Peak CPS**: Highest production rate achieved
- **Total Time Played**: Cumulative play time
- **Session Stats**: Current session time and earnings
- **Total Taps**: Lifetime tap count
- **Total Upgrades**: Purchases made (generators + click upgrades)
- **Prestige Count**: Times prestiged
- **Stellar Shards**: Total earned across prestiges
- **Achievement Progress**: Unlocked / Total achievements
- **Most Valuable Generator**: Highest production unit

### Visualizations

- **Production Chart**: Line graph of credits/sec over last hour
- **Daily Activity**: Heatmap of engagement over last 30 days
- **Achievement Grid**: Progress bars for all achievements
- **Generator Overview**: Current levels and production rates

---

## Achievements

The game features 25+ unique achievements across various categories:

### Achievement Categories

- **Credit Milestones**: Earn specific amounts of credits
- **Generator Progress**: Unlock and upgrade generators
- **Tap Challenges**: Perform certain numbers of taps
- **Prestige Mastery**: Complete multiple prestiges
- **Production Goals**: Reach certain credits/second rates
- **Collection**: Unlock all generators or upgrades

**Rewards**: Each achievement grants a permanent production multiplier bonus (typically +2% to +10% per achievement).

---

## Settings & Customization

### Display Settings

- **Number Notation**: Choose between abbreviated (1.5K) or full (1,500) formats
- **Theme Selection**: Dark, Light, Cosmic, or Nebula themes

### Audio & Haptics

- **Haptic Feedback**: Physical vibration on taps and purchases (iOS devices)
- **Sound Effects**: Toggle for future audio implementation
- **Music**: Toggle for future background music

### Gameplay Options

- **Auto-Buy**: Automatically purchase generators when affordable
  - Global toggle
  - Per-generator configuration
- **Confirm Purchases**: Require confirmation for expensive purchases
- **Affordability Notifications**: Visual badges for affordable items
- **Achievement Notifications**: Show unlock notifications

### Tutorial

- **Interactive Tutorial**: First-launch walkthrough of game mechanics
- **Re-accessible**: Can be viewed again from settings at any time

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2025 Cem

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See [LICENSE](LICENSE) file for full license text.

---

## Development Information

### Project Stats

- **Total Swift Files**: 23
- **Total Lines of Code**: ~4,780
- **Largest File**: GameViewModel.swift (967 lines)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Code Coverage**: Models, Views, ViewModels all implemented
- **External Dependencies**: None (100% native Swift/SwiftUI)

### Code Quality Features

- **Comprehensive Documentation**: All public APIs documented with doc comments
- **Type Safety**: Strong typing throughout with Swift enums and structs
- **Error Handling**: Safe unwrapping and error reporting
- **Memory Management**: Weak references in closures to prevent retain cycles
- **Separation of Concerns**: Clear MVVM boundaries
- **Reusable Components**: Modular view components

### Future Enhancement Ideas

- **iCloud Sync**: Cross-device progress synchronization
- **Game Center Integration**: Leaderboards and achievements
- **Sound Effects**: Audio feedback for interactions
- **Background Music**: Ambient space-themed soundtrack
- **Additional Generators**: More late-game content
- **Special Events**: Time-limited bonuses
- **Multiplayer**: Compare progress with friends
- **Widget Support**: Home screen production tracking
- **macOS Version**: Universal app for Mac Catalyst

---

## Contributing

This is an open-source educational project. Feel free to:

- Report bugs and issues
- Suggest new features
- Submit pull requests for improvements
- Use as a learning resource for SwiftUI/MVVM patterns

---

## Contact & Support

For questions, issues, or suggestions:

- **GitHub Repository**: [Stellar-Forge-Eclipse](https://github.com/cem8kaya/Stellar-Forge-Eclipse)
- **Issues**: Use GitHub Issues for bug reports and feature requests

---

## Acknowledgments

Built with SwiftUI and modern iOS development best practices. Special thanks to the Swift and iOS developer community for excellent documentation and resources.

---

**Happy Mining! May your credits flow like starlight across the cosmos!** 🌟⛏️🚀
