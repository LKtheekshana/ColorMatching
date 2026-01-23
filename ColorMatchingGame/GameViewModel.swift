import SwiftUI
import Combine

enum GameMode: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        }
    }
    
    var timeLimit: Int {
        switch self {
        case .easy: return 30
        case .medium: return 45
        case .hard: return 60
        }
    }
    
    var revealTime: Double {
        switch self {
        case .easy: return 3.0
        case .medium: return 2.5
        case .hard: return 2.0
        }
    }
}

class GameViewModel: ObservableObject {
    @Published var currentMode: GameMode = .easy
    @Published var tiles: [ColorTile] = []
    @Published var targetColor: Color = .blue
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 30
    @Published var isGameActive: Bool = false
    @Published var isRevealing: Bool = false
    @Published var revealProgress: Double = 0.0
    @Published var gameResult: String = ""
    @Published var isGameStarted: Bool = false
    @Published var roundNumber: Int = 0
    
    private var timer: Timer?
    private var revealTimer: Timer?
    private var hideTimer: Timer?
    private var highScores: [String: Int] = [:]
    
    init() {
        loadHighScores()
    }
    
    func startGame(mode: GameMode) {
        currentMode = mode
        timeRemaining = mode.timeLimit
        score = 0
        roundNumber = 0
        isGameActive = true
        isGameStarted = true
        gameResult = ""
        startNewRound()
    }
    
    private func startNewRound() {
        roundNumber += 1
        generateGrid()
        revealColorsTemporarily()
    }
    
    func generateGrid() {
        let size = currentMode.gridSize
        let totalTiles = size * size
        
        // Generate random colors
        var colors: [Color] = []
        for _ in 0..<totalTiles {
            colors.append(generateRandomColor())
        }
        
        // Select target color
        targetColor = colors.randomElement() ?? .blue
        
        // Create tiles (initially hidden)
        tiles = colors.map { color in
            ColorTile(
                color: color,
                isTarget: color == targetColor,
                isRevealed: false,
                isHidden: true
            )
        }.shuffled()
    }
    
    private func generateRandomColor() -> Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
    func revealColorsTemporarily() {
        // Stop any existing timers
        revealTimer?.invalidate()
        hideTimer?.invalidate()
        
        // Reset reveal progress
        revealProgress = 0.0
        isRevealing = true
        
        // Reveal all tiles
        for i in 0..<tiles.count {
            tiles[i].isRevealed = true
            tiles[i].isHidden = false
        }
        objectWillChange.send()
        
        // Start reveal timer (progress bar)
        let revealDuration = currentMode.revealTime
        revealTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.revealProgress += 0.05 / revealDuration
            
            if self.revealProgress >= 1.0 {
                self.revealTimer?.invalidate()
                self.hideColors()
            }
        }
        
        // Set timer to hide colors
        hideTimer = Timer.scheduledTimer(withTimeInterval: revealDuration, repeats: false) { [weak self] _ in
            self?.hideColors()
        }
    }
    
    private func hideColors() {
        isRevealing = false
        revealTimer?.invalidate()
        
        // Hide all tiles
        for i in 0..<tiles.count {
            tiles[i].isRevealed = false
            tiles[i].isHidden = true
        }
        objectWillChange.send()
        
        // Start game timer if this is the first round
        if roundNumber == 1 {
            startTimer()
        }
    }
    
    func tileTapped(_ tile: ColorTile) {
        guard isGameActive && !isRevealing else { return }
        
        // Temporarily reveal the tapped tile
        if let index = tiles.firstIndex(where: { $0.id == tile.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tiles[index].isRevealed = true
            }
            
            // Check if it's the target color
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if tile.color == self.targetColor {
                    self.score += 10 * self.currentMode.gridSize
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.startNewRound()
                    }
                } else {
                    self.score = max(0, self.score - 5)
                    // Hide the tile again after showing it was wrong
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            self.tiles[index].isRevealed = false
                        }
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                
                // Flash warning when time is low
                if self.timeRemaining <= 10 && self.timeRemaining % 2 == 0 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.objectWillChange.send()
                    }
                }
            } else {
                self.endGame()
            }
        }
    }
    
    func endGame() {
        isGameActive = false
        isGameStarted = false
        timer?.invalidate()
        revealTimer?.invalidate()
        hideTimer?.invalidate()
        
        // Save high score
        if score > (highScores[currentMode.rawValue] ?? 0) {
            highScores[currentMode.rawValue] = score
            saveHighScores()
            gameResult = "🎉 New High Score!"
        } else {
            gameResult = "Time's Up!"
        }
    }
    
    func resetGame() {
        isGameActive = false
        isGameStarted = false
        isRevealing = false
        timer?.invalidate()
        revealTimer?.invalidate()
        hideTimer?.invalidate()
        generateGrid()
    }
    
    // MARK: - High Scores
    
    private func saveHighScores() {
        UserDefaults.standard.set(highScores, forKey: "colorGameHighScores")
    }
    
    private func loadHighScores() {
        highScores = UserDefaults.standard.dictionary(forKey: "colorGameHighScores") as? [String: Int] ?? [:]
    }
    
    func getHighScore(for mode: GameMode) -> Int {
        highScores[mode.rawValue] ?? 0
    }
    
    deinit {
        timer?.invalidate()
        revealTimer?.invalidate()
        hideTimer?.invalidate()
    }
}
