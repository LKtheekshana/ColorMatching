// ScoreboardView.swift
import SwiftUI

struct ScoreboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.95, blue: 0.97),
                        Color(red: 0.85, green: 0.89, blue: 0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Tab Selector
                    tabSelectorView
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        highScoresView
                    } else {
                        gameStatsView
                    }
                    
                    Spacer()
                    
                    // Current Game Score
                    if viewModel.score > 0 {
                        currentScoreView
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("🏆 Scoreboard")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            Text("Track Your Performance")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            ForEach(["High Scores", "Game Stats"], id: \.self) { title in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = title == "High Scores" ? 0 : 1
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedTab == (title == "High Scores" ? 0 : 1) ?
                                           Color(red: 0.2, green: 0.2, blue: 0.3) :
                                           Color(red: 0.5, green: 0.5, blue: 0.6))
                        
                        Rectangle()
                            .fill(selectedTab == (title == "High Scores" ? 0 : 1) ?
                                 Color(red: 0.2, green: 0.6, blue: 0.8) :
                                 Color.clear)
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
    
    // MARK: - High Scores View
    
    private var highScoresView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    scoreCard(for: mode)
                }
                
                // Stats Summary
                VStack(spacing: 15) {
                    Text("Summary")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                        .padding(.top, 10)
                    
                    HStack(spacing: 30) {
                        statCard(title: "Total Games", value: "\(totalGamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                        statCard(title: "Best Mode", value: bestMode, icon: "crown.fill", color: .yellow)
                    }
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
        }
    }
    
    private func scoreCard(for mode: GameMode) -> some View {
        let highScore = viewModel.getHighScore(for: mode)
        
        return HStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    // Difficulty Icon
                    difficultyIcon(for: mode)
                    
                    Text(mode.rawValue)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 15) {
                        Label("\(mode.gridSize)×\(mode.gridSize)", systemImage: "grid")
                        Label("\(mode.timeLimit)s", systemImage: "clock")
                        Label("\(String(format: "%.1f", mode.revealTime))s", systemImage: "eye")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    
                    if highScore > 0 {
                        Text("Achieved on \(lastPlayedDate(for: mode))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("HIGH SCORE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1)
                
                if highScore > 0 {
                    Text("\(highScore)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.slash")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Not Played")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 10)
                }
                
                // Medals
                if highScore >= 100 {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                        .padding(.top, 5)
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(scoreCardGradient(mode))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func difficultyIcon(for mode: GameMode) -> some View {
        let iconName: String
        let color: Color
        
        switch mode {
        case .easy:
            iconName = "leaf.fill"
            color = .green
        case .medium:
            iconName = "flame.fill"
            color = .orange
        case .hard:
            iconName = "bolt.fill"
            color = .red
        }
        
        return Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundColor(color)
    }
    
    private func scoreCardGradient(_ mode: GameMode) -> LinearGradient {
        switch mode {
        case .easy:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.8, blue: 0.6), Color(red: 0.1, green: 0.6, blue: 0.5)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .medium:
            return LinearGradient(
                colors: [Color(red: 1, green: 0.6, blue: 0.3), Color(red: 1, green: 0.5, blue: 0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .hard:
            return LinearGradient(
                colors: [Color(red: 1, green: 0.3, blue: 0.3), Color(red: 0.9, green: 0.2, blue: 0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Game Stats View
    
    private var gameStatsView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Performance Metrics
                VStack(spacing: 20) {
                    Text("Performance Metrics")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                        .padding(.bottom, 5)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        statCard(title: "Total Score", value: "\(totalScore)", icon: "star.fill", color: .yellow)
                        statCard(title: "Avg. Score", value: "\(averageScore)", icon: "chart.line.uptrend.xyaxis", color: .green)
                        statCard(title: "Games Played", value: "\(totalGamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                        statCard(title: "Best Score", value: "\(bestOverallScore)", icon: "trophy.fill", color: .orange)
                    }
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                // Mode Comparison
                VStack(spacing: 20) {
                    Text("Mode Comparison")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                    
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        modeComparisonRow(for: mode)
                    }
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                // Tips Section
                tipsView
                    .padding(.horizontal)
            }
            .padding(.vertical, 10)
        }
    }
    
    private func modeComparisonRow(for mode: GameMode) -> some View {
        let highScore = viewModel.getHighScore(for: mode)
        
        return HStack {
            HStack(spacing: 12) {
                difficultyIcon(for: mode)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    
                    Text("Grid: \(mode.gridSize)×\(mode.gridSize)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                }
            }
            
            Spacer()
            
            if highScore > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(highScore) pts")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor(for: highScore))
                    
                    // Score indicator bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.9, green: 0.9, blue: 0.95))
                                .frame(height: 8)
                            
                            let width = min(CGFloat(highScore) / 500.0 * geometry.size.width, geometry.size.width)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(scoreGradient(for: mode))
                                .frame(width: width, height: 8)
                        }
                    }
                    .frame(width: 100, height: 8)
                }
            } else {
                Text("Not Played")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
            }
        }
        .padding(.vertical, 8)
    }
    
    private func scoreGradient(for mode: GameMode) -> LinearGradient {
        switch mode {
        case .easy:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.9, blue: 0.7), Color(red: 0.3, green: 0.8, blue: 0.6)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .medium:
            return LinearGradient(
                colors: [Color(red: 1, green: 0.7, blue: 0.4), Color(red: 1, green: 0.6, blue: 0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .hard:
            return LinearGradient(
                colors: [Color(red: 1, green: 0.4, blue: 0.4), Color(red: 0.9, green: 0.3, blue: 0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var tipsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🎯 Tips to Improve")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            VStack(alignment: .leading, spacing: 12) {
                tipRow(icon: "brain.head.profile", title: "Memory Strategy", description: "Focus on color positions during reveal time")
                tipRow(icon: "clock.badge.checkmark", title: "Time Management", description: "Don't rush - accuracy is better than speed")
                tipRow(icon: "arrow.triangle.2.circlepath", title: "Practice Makes Perfect", description: "Start with Easy mode to build confidence")
                tipRow(icon: "eye.trianglebadge.exclamationmark", title: "Visual Focus", description: "Look for color patterns in the grid")
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.9, green: 0.95, blue: 1.0), Color(red: 0.85, green: 0.92, blue: 0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func tipRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.8))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Current Score View
    
    private var currentScoreView: some View {
        VStack(spacing: 10) {
            Text("Current Game")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            
            HStack(spacing: 15) {
                VStack(spacing: 4) {
                    Text("SCORE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .tracking(1)
                    
                    Text("\(viewModel.score)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(scoreColor(for: viewModel.score))
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 15)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                
                if viewModel.score > viewModel.getHighScore(for: viewModel.currentMode) {
                    VStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                        
                        Text("New Best!")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.7))
                .edgesIgnoringSafeArea(.bottom)
        )
    }
    
    // MARK: - Helper Functions
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        )
    }
    
    private func scoreColor(for score: Int) -> Color {
        if score >= 300 {
            return Color(red: 0.9, green: 0.4, blue: 0.2) // Gold
        } else if score >= 200 {
            return Color(red: 0.7, green: 0.7, blue: 0.9) // Silver
        } else if score >= 100 {
            return Color(red: 0.8, green: 0.5, blue: 0.3) // Bronze
        } else {
            return Color(red: 0.2, green: 0.6, blue: 0.8) // Blue
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
    
    private func lastPlayedDate(for mode: GameMode) -> String {
        // In a real app, you would save and retrieve actual dates
        // For now, return a placeholder
        let dates = ["Jan 15", "Feb 3", "Mar 22", "Apr 10", "May 5"]
        return dates.randomElement() ?? "Recently"
    }
}
