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
    @Published var targetColor: CellColor? = nil
    @Published var targetCount = 0
    @Published var currentCount = 0
    @Published var maxMoves: Int = 0
    @Published var movesLeft: Int = 0

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
        self.targetColor = nil
        self.targetCount = calculateTargetCount()
        self.maxMoves = calculateMaxMoves()
        self.movesLeft = maxMoves
        resetGame()
    }
    
    deinit {
        timer?.invalidate()
    }

    func handleTap(row: Int, col: Int) {
        guard !hasWon else { return }
        
        // Check if moves are exhausted
        if movesLeft <= 0 {
            return
        }
        
        let positions = [(row, col), (row-1,col),(row+1,col),(row,col-1),(row,col+1)]
        for (r,c) in positions {
            if r >= 0 && r < grid.count && c >= 0 && c < grid[r].count {
                grid[r][c] = grid[r][c].next()
            }
        }
        moves += 1
        movesLeft -= 1
        updateScore()
        hintPosition = nil
        updateCurrentCount()
        playTapHaptic()
        checkWinCondition()
    }

    func resetGame() {
        hasWon = false
        moves = 0
        score = 1000
        elapsedTime = 0
        hintPosition = nil
        
        // Start with all gray cells
        grid = Array(repeating: Array(repeating: CellColor.gray, count: mode.gridSize), count: mode.gridSize)
        
        // Set a random target color (excluding gray)
        targetColor = CellColor.playableColors.randomElement()
        targetCount = calculateTargetCount()
        currentCount = 0
        maxMoves = calculateMaxMoves()
        movesLeft = maxMoves
        
        startTimer()
    }

    private func calculateTargetCount() -> Int {
        // More challenging target counts
        let totalCells = mode.gridSize * mode.gridSize
        switch mode {
        case .easy: return Int(Double(totalCells) * 0.6)  // 3x3 = 9 cells, target = 5-6
        case .medium: return Int(Double(totalCells) * 0.7)  // 4x4 = 16 cells, target = 11-12
        case .hard: return Int(Double(totalCells) * 0.8)  // 5x5 = 25 cells, target = 20
        }
    }
    
    private func calculateMaxMoves() -> Int {
        // Limited moves based on difficulty
        switch mode {
        case .easy: return 15
        case .medium: return 20
        case .hard: return 25
        }
    }

    private func updateCurrentCount() {
        guard let target = targetColor else { return }
        var count = 0
        for row in grid {
            for cell in row {
                if cell == target {
                    count += 1
                }
            }
        }
        currentCount = count
    }

    private func updateScore() {
        // More penalty for moves
        let calculatedScore = 1000 - moves * 15
        score = max(calculatedScore, 100)
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, !self.hasWon else { return }
            self.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func checkWinCondition() {
        guard let target = targetColor else { return }
        
        // CHALLENGE 1: Exact count requirement (must have EXACTLY target count)
        if currentCount != targetCount {
            return
        }
        
        // CHALLENGE 2: No adjacent same-colored cells (isolated target cells)
        if hasAdjacentSameColorCells(target: target) {
            return
        }
        
        // If all challenges passed
        hasWon = true
        stopTimer()
        updateBestScore()
        updateBestTime()
        playWinHaptic()
    }
    
    private func hasAdjacentSameColorCells(target: CellColor) -> Bool {
        // Check if any target cell has adjacent target cell
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if grid[row][col] == target {
                    // Check adjacent cells
                    let adjacentPositions = [(row-1, col), (row+1, col), (row, col-1), (row, col+1)]
                    for (r, c) in adjacentPositions {
                        if r >= 0 && r < grid.count && c >= 0 && c < grid[row].count {
                            if grid[r][c] == target {
                                return true // Found adjacent same color
                            }
                        }
                    }
                }
            }
        }
        return false // No adjacent same color cells
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
        guard let target = targetColor else { return }
        
        // Strategic hint: Find a cell that would create adjacent target cells
        var candidates: [(Int, Int, Int)] = [] // (row, col, priority)
        
        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if grid[row][col] != target {
                    // Check if changing this cell would create adjacent target cells
                    let adjacentCount = countAdjacentTargetCells(row: row, col: col, target: target)
                    candidates.append((row, col, adjacentCount))
                }
            }
        }
        
        // Sort by priority (cells that create more adjacent target cells)
        candidates.sort { $0.2 > $1.2 }
        if let bestCandidate = candidates.first {
            hintPosition = (bestCandidate.0, bestCandidate.1)
        }
    }
    
    private func countAdjacentTargetCells(row: Int, col: Int, target: CellColor) -> Int {
        var count = 0
        let directions = [(row-1, col), (row+1, col), (row, col-1), (row, col+1)]
        
        for (r, c) in directions {
            if r >= 0 && r < grid.count && c >= 0 && c < grid.count {
                if grid[r][c] == target {
                    count += 1
                }
            }
        }
        return count
    }

    func submitScore(playerName: String) {
        let entry = LeaderboardEntry(playerName: playerName, score: score, time: elapsedTime)
        LeaderboardManager.shared.save(entry: entry, for: mode.title)
    }

    private func playTapHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func playWinHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
