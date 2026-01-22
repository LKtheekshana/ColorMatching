import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var tappedCell: (row: Int, col: Int)? = nil
    @State private var playerName = ""
    @State private var showLeaderboard = false
    @State private var animateGradient = false
    @State private var showGameOver = false

    init(mode: GameMode) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode))
    }

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: animateGradient ?
                    [.purple.opacity(0.3), .blue.opacity(0.3), .pink.opacity(0.3)] :
                    [.pink.opacity(0.3), .cyan.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            VStack(spacing: 20) {
                header
                targetDisplay
                statsCard
                gridView
                HStack(spacing: 16) {
                    hintButton
                    resetButton
                }
            }
            .padding()

            if viewModel.hasWon {
                winOverlay
            }
            
            if viewModel.movesLeft <= 0 && !viewModel.hasWon {
                gameOverOverlay
            }
        }
        .onChange(of: viewModel.movesLeft) { newValue in
            if newValue <= 0 && !viewModel.hasWon {
                showGameOver = true
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 4) {
            Text("Chromatic Grid")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text("\(viewModel.mode.title) Mode - Expert")
                .font(.title3)
                .foregroundColor(.orange)
        }
    }

    // MARK: - Target Display
    private var targetDisplay: some View {
        VStack(spacing: 12) {
            HStack(spacing: 15) {
                if let targetColor = viewModel.targetColor {
                    // Target color display
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(targetColor.color)
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.3), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        Text(targetColor.description)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                    // Target requirements
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Exactly \(viewModel.targetCount) cells")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("No touching cells")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: viewModel.movesLeft > 5 ? "clock.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(viewModel.movesLeft > 5 ? .blue : .red)
                                .font(.caption)
                            Text("\(viewModel.movesLeft) moves left")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.movesLeft > 5 ? .blue : .red)
                        }
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    VStack(spacing: 8) {
                        Text("Progress")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(min(viewModel.currentCount, viewModel.targetCount)) / CGFloat(viewModel.targetCount))
                                .stroke(
                                    viewModel.currentCount == viewModel.targetCount ? Color.green : Color.blue,
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: viewModel.currentCount)
                            
                            VStack {
                                Text("\(viewModel.currentCount)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(viewModel.currentCount == viewModel.targetCount ? .green : .blue)
                                Text("/\(viewModel.targetCount)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            
            // Progress bar
            VStack(spacing: 5) {
                HStack {
                    Text("Collection Progress")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(viewModel.currentCount)/\(viewModel.targetCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.currentCount == viewModel.targetCount ? .green : .blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(Color.gray.opacity(0.3))
                        
                        Rectangle()
                            .frame(width: min(CGFloat(viewModel.currentCount) / CGFloat(viewModel.targetCount) * geometry.size.width, geometry.size.width), height: 8)
                            .foregroundColor(viewModel.currentCount == viewModel.targetCount ? .green : .blue)
                            .animation(.linear, value: viewModel.currentCount)
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 15) {
            statView(
                title: "Moves",
                value: "\(viewModel.moves)",
                icon: "arrow.clockwise.circle.fill",
                color: .blue
            )
            
            statView(
                title: "Left",
                value: "\(viewModel.movesLeft)",
                icon: viewModel.movesLeft > 5 ? "number.circle.fill" : "exclamationmark.circle.fill",
                color: viewModel.movesLeft > 5 ? .green : .red
            )
            
            statView(
                title: "Score",
                value: "\(viewModel.score)",
                icon: "trophy.fill",
                color: .orange
            )
            
            statView(
                title: "Time",
                value: formatTime(viewModel.elapsedTime),
                icon: "clock.fill",
                color: .purple
            )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func statView(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Grid View
    private var gridView: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let spacing: CGFloat = 8
            let squareSize = (size - spacing * CGFloat(viewModel.mode.gridSize - 1)) / CGFloat(viewModel.mode.gridSize)

            VStack(spacing: spacing) {
                ForEach(0..<viewModel.mode.gridSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<viewModel.mode.gridSize, id: \.self) { col in
                            CellView(
                                color: viewModel.grid[row][col].color,
                                size: squareSize,
                                isTapped: tappedCell?.row == row && tappedCell?.col == col,
                                isHint: viewModel.hintPosition?.row == row && viewModel.hintPosition?.col == col,
                                isWon: viewModel.hasWon
                            ) {
                                tappedCell = (row, col)
                                viewModel.handleTap(row: row, col: col)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    tappedCell = nil
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Hint Button
    private var hintButton: some View {
        Button {
            viewModel.giveHint()
        } label: {
            HStack {
                Image(systemName: "lightbulb.fill")
                Text("Hint")
            }
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Reset Button
    private var resetButton: some View {
        Button {
            viewModel.resetGame()
            playerName = ""
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Restart")
            }
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Win Overlay
    private var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            ConfettiView()

            VStack(spacing: 25) {
                Text("🏆 Master Achieved!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 6) {
                    Text("Perfect Strategy!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("You collected exactly \(viewModel.currentCount) \(viewModel.targetColor?.description ?? "") cells")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 12) {
                    StatRow(label: "Moves Used:", value: "\(viewModel.moves)", color: .blue)
                    StatRow(label: "Moves Left:", value: "\(viewModel.movesLeft)", color: .green)
                    StatRow(label: "Final Score:", value: "\(viewModel.score)", color: .orange)
                    StatRow(label: "Time:", value: formatTime(viewModel.elapsedTime), color: .purple)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                VStack(spacing: 15) {
                    TextField("Enter your name for leaderboard", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Button {
                            let name = playerName.isEmpty ? "Player" : playerName
                            viewModel.submitScore(playerName: name)
                            showLeaderboard = true
                        } label: {
                            HStack {
                                Image(systemName: "trophy.fill")
                                Text("Submit Score")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                        }

                        Button {
                            viewModel.resetGame()
                            playerName = ""
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play Again")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 25)
            .padding(40)
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView(mode: viewModel.mode)
            }
        }
    }
    
    // MARK: - Game Over Overlay
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("⏰ Time's Up!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                
                VStack(spacing: 6) {
                    Text("Out of Moves")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("You needed \(viewModel.targetCount - viewModel.currentCount) more \(viewModel.targetColor?.description ?? "") cells")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 12) {
                    StatRow(label: "Target Cells:", value: "\(viewModel.currentCount)/\(viewModel.targetCount)", color: .blue)
                    StatRow(label: "Moves Used:", value: "\(viewModel.moves)", color: .orange)
                    StatRow(label: "Final Score:", value: "\(viewModel.score)", color: .green)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                HStack(spacing: 16) {
                    Button {
                        viewModel.resetGame()
                        playerName = ""
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Try Again")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    }

                    Button {
                        // Go back to main menu or show tips
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb")
                            Text("Get Tips")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 25)
            .padding(40)
        }
    }
}

// Helper view for stat rows
struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}
