//
//  GameView.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-16.
//
import SwiftUI
import UIKit

struct GameView: View {
    let mode: GameMode
    @State private var grid: [[CellColor]]
    @State private var hasWon = false
    @State private var animateGradient = false
    @State private var tappedCell: (row: Int, col: Int)? = nil

    init(mode: GameMode) {
        self.mode = mode
        self._grid = State(
            initialValue: Array(
                repeating: Array(repeating: .gray, count: mode.rawValue),
                count: mode.rawValue
            )
        )
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: animateGradient ? [.purple, .blue, .pink] : [.blue, .purple, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }

            // Main Content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Chromatic Grid")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)

                    Text("\(mode.title) Mode")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.85))
                }

                // Grid
                GeometryReader { geometry in
                    let gridSize = min(geometry.size.width, geometry.size.height)
                    let spacing: CGFloat = 10
                    let squareSize = (gridSize - spacing * CGFloat(mode.rawValue - 1)) / CGFloat(mode.rawValue)

                    VStack(spacing: spacing) {
                        ForEach(0..<mode.rawValue, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(0..<mode.rawValue, id: \.self) { col in
                                    Button {
                                        tappedCell = (row, col)
                                        handleTap(row: row, col: col)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            tappedCell = nil
                                        }
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(grid[row][col].color)
                                                .overlay(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                                .scaleEffect(tappedCell?.row == row && tappedCell?.col == col ? 1.15 : (hasWon ? 1.05 : 1))
                                                .brightness(hasWon ? 0.1 : 0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: grid[row][col])
                                        }
                                        .frame(width: squareSize, height: squareSize)
                                    }
                                    .disabled(hasWon)
                                }
                            }
                        }
                    }
                    .frame(width: gridSize, height: gridSize, alignment: .center)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                .frame(height: UIScreen.main.bounds.width)

                // Reset Button – modern filled style
                Button(action: {
                    resetGame()
                }) {
                    Text("Reset Game")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.25), radius: 5, x: 2, y: 2)
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Win Overlay – modern button
            if hasWon {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Text("🎉 You Win!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Button(action: {
                            resetGame()
                        }) {
                            Text("Play Again")
                                .fontWeight(.bold)
                                .frame(maxWidth: 200)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.25), radius: 5, x: 2, y: 2)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.8))
                            .shadow(radius: 10)
                    )
                }
                .zIndex(1)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(), value: hasWon)
            }
        }
    }

    // MARK: - Game Logic
    func handleTap(row: Int, col: Int) {
        guard !hasWon else { return }
        grid[row][col] = grid[row][col].next()
        playTapHaptic()
        checkWinCondition()
    }

    func checkWinCondition() {
        let first = grid[0][0]
        guard first.isPlayableColor else { return }

        for row in grid {
            for cell in row where cell != first { return }
        }

        hasWon = true
        playWinHaptic()
    }

    func resetGame() {
        hasWon = false
        grid = Array(
            repeating: Array(repeating: .gray, count: mode.rawValue),
            count: mode.rawValue
        )
    }

    // MARK: - Haptic Feedback
    func playTapHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func playWinHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
