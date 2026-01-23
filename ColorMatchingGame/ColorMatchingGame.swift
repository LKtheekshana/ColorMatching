// ColorMatchingGame.swift
import SwiftUI

struct ColorMatchingGame: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingScoreboard = false
    
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
                    
                    // Game area
                    if !viewModel.isGameStarted {
                        modeSelectionView
                    } else {
                        gameView
                    }
                    
                    Spacer()
                    
                    // Bottom navigation
                    bottomNavigationView
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingScoreboard) {
                ScoreboardView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Color Match")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            Text(viewModel.isGameStarted ? "Memory Challenge" : "Find the matching color")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Mode Selection View
    
    private var modeSelectionView: some View {
        VStack(spacing: 30) {
            Text("Select Difficulty")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
            
            ForEach(GameMode.allCases, id: \.self) { mode in
                modeButton(mode: mode)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private func modeButton(mode: GameMode) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                viewModel.startGame(mode: mode)
            }
        }) {
            VStack(spacing: 12) {
                Text(mode.rawValue)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 15) {
                    Label("\(mode.gridSize)×\(mode.gridSize)", systemImage: "square.grid.2x2")
                    Label("\(mode.timeLimit)s", systemImage: "clock")
                    Label("\(String(format: "%.1f", mode.revealTime))s", systemImage: "eye")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            }
            .frame(width: 280)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(modeGradient(mode))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func modeGradient(_ mode: GameMode) -> LinearGradient {
        switch mode {
        case .easy:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.8, blue: 0.6), Color(red: 0.1, green: 0.7, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .medium:
            return LinearGradient(
                colors: [Color(red: 1, green: 0.6, blue: 0.3), Color(red: 1, green: 0.4, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hard:
            return LinearGradient(
                colors: [Color(red: 1, green: 0.3, blue: 0.3), Color(red: 0.8, green: 0.2, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Game View
    
    private var gameView: some View {
        VStack(spacing: 25) {
            // Score and Timer
            HStack {
                scoreView
                Spacer()
                timerView
            }
            .padding(.horizontal)
            
            // Reveal Progress
            if viewModel.isRevealing {
                revealProgressView
            }
            
            // Target Color Display
            targetColorView
            
            // Game Status
            gameStatusView
            
            // Grid
            gridView
            
            // Instructions
            instructionsView
        }
        .padding(.top, 10)
    }
    
    private var scoreView: some View {
        HStack(spacing: 10) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("\(viewModel.score)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
    
    private var timerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.fill")
                .foregroundColor(timeColor)
            Text("\(viewModel.timeRemaining)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(timeColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
    
    private var timeColor: Color {
        if viewModel.timeRemaining <= 10 {
            return Color.red
        } else if viewModel.timeRemaining <= 20 {
            return Color.orange
        }
        return Color.green
    }
    
    private var revealProgressView: some View {
        VStack(spacing: 8) {
            Text("Memorize the colors!")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.2))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.8, blue: 0.6), Color(red: 0.1, green: 0.7, blue: 0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(viewModel.revealProgress), height: 12)
                }
            }
            .frame(height: 12)
            .padding(.horizontal, 30)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var targetColorView: some View {
        VStack(spacing: 15) {
            Text("Find this color:")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(viewModel.targetColor)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 4)
                    )
                
                if !viewModel.isGameActive {
                    Image(systemName: "questionmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3)
                }
            }
        }
    }
    
    private var gameStatusView: some View {
        Group {
            if !viewModel.gameResult.isEmpty {
                Text(viewModel.gameResult)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                    .transition(.scale)
            } else if viewModel.isRevealing {
                Text("Memorizing...")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.8))
            } else {
                Text("Round \(viewModel.roundNumber)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            }
        }
    }
    
    private var gridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: viewModel.currentMode.gridSize)
        
        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(viewModel.tiles) { tile in
                tileView(tile)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal)
    }
    
    private func tileView(_ tile: ColorTile) -> some View {
        Button(action: {
            guard viewModel.isGameActive && !viewModel.isRevealing else { return }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.tileTapped(tile)
            }
        }) {
            ZStack {
                // Hidden state (question mark)
                if !tile.isRevealed && tile.isHidden {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.9, green: 0.9, blue: 0.95), Color(red: 0.8, green: 0.85, blue: 0.92)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        )
                }
                // Revealed state (actual color)
                else if tile.isRevealed {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(tile.color)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Group {
                                if tile.color == viewModel.targetColor && tile.isRevealed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 3)
                                }
                            }
                        )
                }
                // Flipping animation state
                else {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.9, green: 0.9, blue: 0.95), Color(red: 0.8, green: 0.85, blue: 0.92)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            .rotation3DEffect(
                .degrees(tile.isRevealed ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: tile.isRevealed)
        }
        .buttonStyle(TileButtonStyle())
        .disabled(viewModel.isRevealing || !viewModel.isGameActive)
    }
    
    private var instructionsView: some View {
        Text(viewModel.isRevealing ? "Memorize the colors quickly!" : "Tap to find the matching color")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            .padding(.top, 10)
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigationView: some View {
        HStack(spacing: 20) {
            Button(action: {
                showingScoreboard = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                    Text("Scores")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.8))
                )
            }
            
            if viewModel.isGameStarted {
                Button(action: {
                    withAnimation {
                        viewModel.endGame()
                    }
                }) {
                    Text("End Game")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.red)
                        )
                }
            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Button Styles

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
