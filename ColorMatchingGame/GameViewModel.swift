//
//  GameViewModel.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-17.
//
import SwiftUI
import Combine
import UIKit

final class GameViewModel: ObservableObject {
    @Published var grid: [[CellColor]]
    @Published var hasWon = false
    @Published var moves = 0
    @Published var score = 1000
    @Published var bestScore: Int
    @Published var elapsedTime = 0
    @Published var bestTime: Int
    @Published var hintPosition: (row: Int, col: Int)? = nil

    let mode: GameMode
    private let bestScoreKey: String
    private let bestTimeKey: String
    private var timer: Timer?

    init(mode: GameMode) {
        self.mode = mode
        self.bestScoreKey = "BestScore_\(mode.title)"
        self.bestTimeKey = "BestTime_\(mode.title)"
        self.bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
        self.bestTime = UserDefaults.standard.integer(forKey: bestTimeKey)
        self.grid = []
        resetGame()
    }

    func handleTap(row: Int, col: Int) {
        guard !hasWon else { return }
        let positions = [(row, col), (row-1,col),(row+1,col),(row,col-1),(row,col+1)]
        for (r,c) in positions {
            if r >= 0 && r < grid.count && c >= 0 && c < grid[r].count {
                grid[r][c] = grid[r][c].next()
            }
        }
        moves += 1
        updateScore()
        hintPosition = nil
        playTapHaptic()
        checkWinCondition()
    }

    func resetGame() {
        hasWon = false
        moves = 0
        score = 1000
        elapsedTime = 0
        hintPosition = nil
        grid = Array(repeating: Array(repeating: CellColor.playableColors.randomElement()!, count: mode.gridSize), count: mode.gridSize)
        startTimer()
    }

    private func updateScore() { score = max(1000 - moves*20, 100) }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, !self.hasWon else { return }
            self.elapsedTime += 1
        }
    }

    private func stopTimer() { timer?.invalidate(); timer=nil }

    private func checkWinCondition() {
        let first = grid[0][0]
        for row in grid {
            for cell in row where cell != first { return }
        }
        hasWon = true
        stopTimer()
        updateBestScore()
        updateBestTime()
        playWinHaptic()
    }

    private func updateBestScore() {
        if bestScore == 0 || score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
        }
    }

    private func updateBestTime() {
        if bestTime == 0 || elapsedTime < bestTime {
            bestTime = elapsedTime
            UserDefaults.standard.set(bestTime, forKey: bestTimeKey)
        }
    }

    func giveHint() {
        let target = grid[0][0]
        var candidates: [(Int,Int)] = []
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if grid[row][col] != target { candidates.append((row,col)) }
            }
        }
        hintPosition = candidates.randomElement()
    }

    func submitScore(playerName: String) {
        let entry = LeaderboardEntry(playerName: playerName, score: score, time: elapsedTime)
        LeaderboardManager.shared.save(entry: entry, for: mode.title)
    }

    private func playTapHaptic() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    private func playWinHaptic() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
