import SwiftUI

struct ScoreboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedTab: Int = 0
    @State private var selectedMode: GameMode = .easy
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header - Fixed height
                    headerView
                        .frame(height: 100)
                    
                    // Mode Picker and Tab Selector
                    VStack(spacing: 0) {
                        // Mode Picker
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        // Tab Selector
                        tabSelectorView
                            .frame(height: 50)
                    }
                    .background(Color.white)
                    
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
                // Top High Score Card
                if let topScore = viewModel.getHighScores(for: selectedMode).first {
                    topScoreCard(score: topScore)
                        .padding(.horizontal, 15)
                }
                
                // High Scores List
                VStack(spacing: 12) {
                    Text("Leaderboard - \(selectedMode.rawValue)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 5)
                    
                    if viewModel.getHighScores(for: selectedMode).isEmpty {
                        emptyHighScoresView
                    } else {
                        highScoresListView
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
    
    private func topScoreCard(score: HighScore) -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Score")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(score.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("SCORE")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Text("\(score.score)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Label("\(selectedMode.gridSize)×\(selectedMode.gridSize)", systemImage: "grid")
                Label("\(selectedMode.timeLimit)s", systemImage: "clock")
                Label("\(String(format: "%.1f", selectedMode.revealTime))s", systemImage: "eye")
                Label("\(selectedMode.targetMatches)×", systemImage: "target")
                Spacer()
                Text(score.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.gray)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var highScoresListView: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.getHighScores(for: selectedMode).enumerated()), id: \.element.id) { index, score in
                highScoreRow(score: score, rank: index + 1)
                
                if index < viewModel.getHighScores(for: selectedMode).count - 1 {
                    Divider()
                        .padding(.horizontal, 10)
                }
            }
        }
    }
    
    private func highScoreRow(score: HighScore, rank: Int) -> some View {
        HStack(spacing: 12) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankBadgeColor(rank))
                    .frame(width: 36, height: 36)
                
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(score.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(score.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(score.score)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
    }
    
    private func rankBadgeColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private var emptyHighScoresView: some View {
        VStack(spacing: 15) {
            Image(systemName: "trophy.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No High Scores Yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            Text("Play \(selectedMode.rawValue) mode to set the first record!")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }
    
    // MARK: - Game Stats View
    
    private var gameStatsView: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Player Info Card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Player")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(viewModel.playerName.isEmpty ? "Guest" : viewModel.playerName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Text("Total Games: \(totalGamesPlayed)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Performance Metrics
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        statCard(title: "Total Score", value: "\(totalScore)", icon: "star.fill", color: .yellow)
                        statCard(title: "Avg. Score", value: "\(averageScore)", icon: "chart.line.uptrend.xyaxis", color: .green)
                        statCard(title: "Best Score", value: "\(bestOverallScore)", icon: "trophy.fill", color: .orange)
                        statCard(title: "Best Mode", value: "\(bestMode)", icon: "crown.fill", color: .purple)
                    }
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
                .padding(.horizontal, 15)
                
                // Mode Performance
                VStack(spacing: 15) {
                    Text("Mode Performance")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        modePerformanceRow(mode: mode)
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
    
    private func modePerformanceRow(mode: GameMode) -> some View {
        let scores = viewModel.getHighScores(for: mode)
        let topScore = scores.first?.score ?? 0
        
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Best: \(topScore)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(scores.count) records")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            // Score indicator
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    let width = min(CGFloat(topScore) / 500.0 * geometry.size.width, geometry.size.width)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(modeColor(for: mode))
                        .frame(width: width, height: 6)
                }
            }
            .frame(width: 60, height: 6)
        }
        .padding(.vertical, 8)
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
    
    private func modeColor(for mode: GameMode) -> Color {
        switch mode {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private var totalScore: Int {
        viewModel.getHighScores(for: .easy).reduce(0) { $0 + $1.score } +
        viewModel.getHighScores(for: .medium).reduce(0) { $0 + $1.score } +
        viewModel.getHighScores(for: .hard).reduce(0) { $0 + $1.score }
    }
    
    private var totalGamesPlayed: Int {
        viewModel.getHighScores(for: .easy).count +
        viewModel.getHighScores(for: .medium).count +
        viewModel.getHighScores(for: .hard).count
    }
    
    private var averageScore: Int {
        guard totalGamesPlayed > 0 else { return 0 }
        return totalScore / totalGamesPlayed
    }
    
    private var bestOverallScore: Int {
        let easyBest = viewModel.getHighScores(for: .easy).first?.score ?? 0
        let mediumBest = viewModel.getHighScores(for: .medium).first?.score ?? 0
        let hardBest = viewModel.getHighScores(for: .hard).first?.score ?? 0
        return max(easyBest, mediumBest, hardBest)
    }
    
    private var bestMode: String {
        let easyBest = viewModel.getHighScores(for: .easy).first?.score ?? 0
        let mediumBest = viewModel.getHighScores(for: .medium).first?.score ?? 0
        let hardBest = viewModel.getHighScores(for: .hard).first?.score ?? 0
        
        if easyBest >= mediumBest && easyBest >= hardBest {
            return "Easy"
        } else if mediumBest >= easyBest && mediumBest >= hardBest {
            return "Medium"
        } else {
            return "Hard"
        }
    }
}
