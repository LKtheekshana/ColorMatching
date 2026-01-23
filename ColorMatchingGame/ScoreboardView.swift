import SwiftUI

struct ScoreboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header - Fixed height
                    headerView
                        .frame(height: 100)
                    
                    // Tab Selector - Fixed height
                    tabSelectorView
                        .frame(height: 50)
                    
                    // Content - Takes remaining space
                    if selectedTab == 0 {
                        highScoresView
                    } else {
                        gameStatsView
                    }
                    
                    // Current Score - Fixed height
                    if viewModel.score > 0 {
                        currentScoreView
                            .frame(height: 80)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("🏆 Scoreboard")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Text("Track Your Performance")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(["High Scores", "Game Stats"], id: \.self) { title in
                Button(action: {
                    withAnimation {
                        selectedTab = title == "High Scores" ? 0 : 1
                    }
                }) {
                    VStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(selectedTab == (title == "High Scores" ? 0 : 1) ?
                                           .blue : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == (title == "High Scores" ? 0 : 1) ?
                                 Color.blue : Color.clear)
                            .frame(height: 3)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(Color.white)
    }
    
    // MARK: - High Scores View
    
    private var highScoresView: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    scoreCard(for: mode)
                        .padding(.horizontal, 15)
                }
                
                // Stats Summary
                VStack(spacing: 12) {
                    Text("Summary")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 5)
                    
                    HStack(spacing: 25) {
                        statCard(title: "Total Games", value: "\(totalGamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                        statCard(title: "Best Mode", value: bestMode, icon: "crown.fill", color: .orange)
                    }
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
                .padding(.horizontal, 15)
                .padding(.top, 5)
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
    }
    
    private func scoreCard(for mode: GameMode) -> some View {
        let highScore = viewModel.getHighScore(for: mode)
        
        return HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    // Difficulty Icon
                    Image(systemName: difficultyIcon(for: mode))
                        .font(.system(size: 16))
                        .foregroundColor(modeColor(for: mode))
                    
                    Text(mode.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 12) {
                    Label("\(mode.gridSize)×\(mode.gridSize)", systemImage: "grid")
                    Label("\(mode.timeLimit)s", systemImage: "clock")
                    Label("\(String(format: "%.1f", mode.revealTime))s", systemImage: "eye")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("HIGH SCORE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1)
                
                if highScore > 0 {
                    Text("\(highScore)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "trophy.slash")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Not Played")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(modeGradient(for: mode))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
    
    private func difficultyIcon(for mode: GameMode) -> String {
        switch mode {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }
    
    private func modeColor(for mode: GameMode) -> Color {
        switch mode {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private func modeGradient(for mode: GameMode) -> LinearGradient {
        switch mode {
        case .easy:
            return LinearGradient(
                gradient: Gradient(colors: [.green, .green.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .medium:
            return LinearGradient(
                gradient: Gradient(colors: [.orange, .orange.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .hard:
            return LinearGradient(
                gradient: Gradient(colors: [.red, .red.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Game Stats View
    
    private var gameStatsView: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Performance Metrics
                VStack(spacing: 15) {
                    Text("Performance Metrics")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.bottom, 5)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        statCard(title: "Total Score", value: "\(totalScore)", icon: "star.fill", color: .yellow)
                        statCard(title: "Avg. Score", value: "\(averageScore)", icon: "chart.line.uptrend.xyaxis", color: .green)
                        statCard(title: "Games Played", value: "\(totalGamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                        statCard(title: "Best Score", value: "\(bestOverallScore)", icon: "trophy.fill", color: .orange)
                    }
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
                .padding(.horizontal, 15)
                
                // Tips Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎯 Tips to Improve")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        tipRow(icon: "brain.head.profile", title: "Memory Strategy", description: "Focus on color positions during reveal time")
                        tipRow(icon: "clock.badge.checkmark", title: "Time Management", description: "Don't rush - accuracy is better than speed")
                        tipRow(icon: "arrow.triangle.2.circlepath", title: "Practice Makes Perfect", description: "Start with Easy mode to build confidence")
                    }
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
                .padding(.horizontal, 15)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical, 10)
        }
        .background(Color(.systemGray6))
    }
    
    private func tipRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Current Score View
    
    private var currentScoreView: some View {
        VStack(spacing: 8) {
            Text("Current Game")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                VStack(spacing: 3) {
                    Text("SCORE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .tracking(1)
                    
                    Text("\(viewModel.score)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(scoreColor(for: viewModel.score))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
                
                if viewModel.score > viewModel.getHighScore(for: viewModel.currentMode) {
                    VStack(spacing: 3) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                        
                        Text("New Best!")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    // MARK: - Helper Functions
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
        )
    }
    
    private func scoreColor(for score: Int) -> Color {
        if score >= 300 {
            return .orange
        } else if score >= 200 {
            return .purple
        } else if score >= 100 {
            return .blue
        } else {
            return .green
        }
    }
    
    private var totalScore: Int {
        GameMode.allCases.reduce(0) { $0 + viewModel.getHighScore(for: $1) }
    }
    
    private var totalGamesPlayed: Int {
        GameMode.allCases.filter { viewModel.getHighScore(for: $0) > 0 }.count
    }
    
    private var averageScore: Int {
        let playedModes = GameMode.allCases.filter { viewModel.getHighScore(for: $0) > 0 }
        guard !playedModes.isEmpty else { return 0 }
        return totalScore / playedModes.count
    }
    
    private var bestOverallScore: Int {
        GameMode.allCases.map { viewModel.getHighScore(for: $0) }.max() ?? 0
    }
    
    private var bestMode: String {
        let modeScores = GameMode.allCases.map { (mode: $0, score: viewModel.getHighScore(for: $0)) }
        let best = modeScores.max { $0.score < $1.score }
        return best?.mode.rawValue ?? "None"
    }
}
