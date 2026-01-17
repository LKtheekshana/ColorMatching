//
//  GameView.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-16.
//
import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var tappedCell: (row: Int, col: Int)? = nil
    @State private var playerName = ""
    @State private var showLeaderboard = false
    @State private var animateGradient = false

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

            VStack(spacing: 24) {
                header
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
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("Chromatic Grid")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)

            Text("\(viewModel.mode.title) Mode")
                .font(.title3)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 24) {
            statView(title: "Moves", value: "\(viewModel.moves)")
            statView(title: "Score", value: "\(viewModel.score)")
            statView(title: "Time", value: formatTime(viewModel.elapsedTime))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func statView(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(.black)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Grid View
    private var gridView: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let spacing: CGFloat = 12
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
            .padding()
            .background(Color.yellow.opacity(0.9))
            .foregroundColor(.black)
            .cornerRadius(12)
        }
    }

    // MARK: - Reset Button
    private var resetButton: some View {
        Button("Reset") {
            viewModel.resetGame()
            playerName = ""
        }
        .fontWeight(.semibold)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .foregroundColor(.black)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // MARK: - Win Overlay
    private var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ConfettiView() // Optional: confetti effect

            VStack(spacing: 14) {
                Text("🎉 You Win!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Moves: \(viewModel.moves)  Score: \(viewModel.score)  Time: \(formatTime(viewModel.elapsedTime))")
                    .font(.headline)

                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                HStack(spacing: 10) {
                    Button("Submit Score") {
                        let name = playerName.isEmpty ? "Player" : playerName
                        viewModel.submitScore(playerName: name)
                        showLeaderboard = true
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)

                    Button("Play Again") {
                        viewModel.resetGame()
                        playerName = ""
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 8)
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView(mode: viewModel.mode)
            }
        }
    }
}
