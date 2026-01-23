import SwiftUI
import Combine

struct HighScore: Identifiable, Codable {
    let id = UUID()
    let name: String
    let score: Int
    let mode: String
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum GameMode: String, CaseIterable, Codable {
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
        case .easy: return 2.0
        case .medium: return 1.0
        case .hard: return 0.5
        }
    }
    
    var targetMatches: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
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
    @Published var matchesFound: Int = 0
    @Published var totalMatchesInRound: Int = 1
    @Published var showNameInput: Bool = false
    @Published var playerName: String = ""
    
    private var timer: Timer?
    private var revealTimer: Timer?
    private var hideTimer: Timer?
    private var highScores: [HighScore] = []
    
    init() {
        loadHighScores()
        loadPlayerName()
    }
    
    func startGame(mode: GameMode) {
        currentMode = mode
        timeRemaining = mode.timeLimit
        score = 0
        roundNumber = 0
        matchesFound = 0
        isGameActive = true
        isGameStarted = true
        gameResult = ""
        showNameInput = false
        startNewRound()
    }
    
    private func startNewRound() {
        roundNumber += 1
        matchesFound = 0
        totalMatchesInRound = currentMode.targetMatches
        generateGrid()
        revealColorsTemporarily()
    }
    
    func generateGrid() {
        let size = currentMode.gridSize
        let totalTiles = size * size
        
        // Generate unique random colors
        var colors: [Color] = []
        for _ in 0..<(totalTiles - currentMode.targetMatches) {
            colors.append(generateRandomColor())
        }
        
        // Select target color
        targetColor = generateRandomColor()
        
        // Add target color multiple times based on difficulty
        for _ in 0..<currentMode.targetMatches {
            colors.append(targetColor)
        }
        
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
                    self.matchesFound += 1
                    self.score += 10 * self.currentMode.gridSize
                    
                    // Mark this tile as found (keep it revealed)
                    self.tiles[index].isHidden = false
                    
                    // Check if all matches are found
                    if self.matchesFound >= self.totalMatchesInRound {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.startNewRound()
                        }
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
        
        // Check if it's a high score
        if isHighScore() {
            gameResult = "🎉 New High Score!"
            showNameInput = true
        } else {
            gameResult = "Time's Up!"
        }
    }
    
    func saveScore() {
        guard !playerName.isEmpty else { return }
        
        let newHighScore = HighScore(
            name: playerName,
            score: score,
            mode: currentMode.rawValue,
            date: Date()
        )
        
        highScores.append(newHighScore)
        // Sort by score descending
        highScores.sort { $0.score > $1.score }
        // Keep only top 10 scores per mode
        highScores = Array(highScores.prefix(30)) // 10 per mode × 3 modes
        
        saveHighScores()
        savePlayerName()
        showNameInput = false
    }
    
    private func isHighScore() -> Bool {
        let modeScores = highScores.filter { $0.mode == currentMode.rawValue }
        // Consider it a high score if it's in top 10 for that mode
        return modeScores.count < 10 || score > (modeScores.last?.score ?? 0)
    }
    
    func getHighScore(for mode: GameMode) -> Int {
        let modeScores = highScores.filter { $0.mode == mode.rawValue }
        return modeScores.first?.score ?? 0
    }
    
    func getHighScores(for mode: GameMode) -> [HighScore] {
        highScores.filter { $0.mode == mode.rawValue }
    }
    
    func resetGame() {
        isGameActive = false
        isGameStarted = false
        isRevealing = false
        matchesFound = 0
        showNameInput = false
        timer?.invalidate()
        revealTimer?.invalidate()
        hideTimer?.invalidate()
        generateGrid()
    }
    
    // MARK: - High Scores Storage
    
    private func saveHighScores() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: "colorGameHighScores")
        }
    }
    
    private func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: "colorGameHighScores"),
           let decoded = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = decoded
        }
    }
    
    private func savePlayerName() {
        UserDefaults.standard.set(playerName, forKey: "playerName")
    }
    
    private func loadPlayerName() {
        playerName = UserDefaults.standard.string(forKey: "playerName") ?? ""
    }
    
    deinit {
        timer?.invalidate()
        revealTimer?.invalidate()
        hideTimer?.invalidate()
    }
}
