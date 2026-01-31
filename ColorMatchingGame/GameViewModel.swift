import SwiftUI
import Combine
import FirebaseAuth

struct HighScore: Identifiable, Codable {
    var id = UUID()
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
    case levelUp = "Level Up"
    
    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 4
        case .hard: return 5
        case .levelUp: return 3  // Starts at Easy
        }
    }
    
    var timeLimit: Int {
        switch self {
        case .easy: return 30
        case .medium: return 45
        case .hard: return 60
        case .levelUp: return 30  // Starts at Easy
        }
    }
    
    var revealTime: Double {
        switch self {
        case .easy: return 2.0
        case .medium: return 1.0
        case .hard: return 0.5
        case .levelUp: return 2.0  // Starts at Easy
        }
    }
    
    var targetMatches: Int {
        switch self {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        case .levelUp: return 1  // Starts at Easy
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
    @Published var currentLevel: Int = 1  // NEW! For Level Up mode
    
    private var timer: Timer?
    private var revealTimer: Timer?
    private var hideTimer: Timer?
    private var highScores: [HighScore] = []
    
    // NEW! For Level Up mode difficulty progression
    private var levelUpGridSize: Int = 3
    private var levelUpTimeLimit: Int = 30
    private var levelUpRevealTime: Double = 2.0
    private var levelUpTargetMatches: Int = 1
    
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
        currentLevel = 1  // NEW! Reset level
        
        // NEW! Initialize Level Up mode parameters
        if mode == .levelUp {
            levelUpGridSize = 3
            levelUpTimeLimit = 30
            levelUpRevealTime = 2.0
            levelUpTargetMatches = 1
        }
        
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
        let size = currentMode == .levelUp ? levelUpGridSize : currentMode.gridSize
        let targetMatches = currentMode == .levelUp ? levelUpTargetMatches : currentMode.targetMatches
        
        let totalTiles = size * size
        
        // Generate unique random colors
        var colors: [Color] = []
        for _ in 0..<(totalTiles - targetMatches) {
            colors.append(generateRandomColor())
        }
        
        // Select target color
        targetColor = generateRandomColor()
        
        // Add target color multiple times based on difficulty
        for _ in 0..<targetMatches {
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
        
        isRevealing = true
        revealProgress = 0.0
        
        let revealDuration = currentMode == .levelUp ? levelUpRevealTime : currentMode.revealTime
        let updateInterval = 0.05
        let steps = Int(revealDuration / updateInterval)
        var currentStep = 0
        
        revealTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            currentStep += 1
            self.revealProgress = Double(currentStep) / Double(steps)
            
            if currentStep >= steps {
                self.revealProgress = 1.0
                self.revealTimer?.invalidate()
                self.revealTimer = nil
                
                // Reveal all tiles
                for i in 0..<self.tiles.count {
                    self.tiles[i].isRevealed = true
                }
                self.objectWillChange.send()
                
                // Hide after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.hideColors()
                }
            }
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
                    
                    // Add points based on mode
                    let gridSize = self.currentMode == .levelUp ? self.levelUpGridSize : self.currentMode.gridSize
                    self.score += 10 * gridSize
                    
                    // Mark this tile as found (keep it revealed)
                    self.tiles[index].isHidden = false
                    
                    // Check if all matches are found
                    if self.matchesFound >= self.totalMatchesInRound {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // NEW! Check if Level Up mode
                            if self.currentMode == .levelUp {
                                self.levelUp()  // Level up instead of next round
                            } else {
                                self.startNewRound()
                            }
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
    
    // NEW! Level Up method
    private func levelUp() {
        currentLevel += 1
        roundNumber = 0
        
        // Increase difficulty based on level
        let nextGridSize: Int
        let nextTimeLimit: Int
        let nextRevealTime: Double
        let nextTargetMatches: Int
        
        switch currentLevel {
        case 1:
            nextGridSize = 3
            nextTimeLimit = 30
            nextRevealTime = 2.0
            nextTargetMatches = 1
        case 2:
            nextGridSize = 3
            nextTimeLimit = 25
            nextRevealTime = 1.8
            nextTargetMatches = 1
        case 3:
            nextGridSize = 4
            nextTimeLimit = 20
            nextRevealTime = 1.5
            nextTargetMatches = 2
        case 4:
            nextGridSize = 4
            nextTimeLimit = 18
            nextRevealTime = 1.2
            nextTargetMatches = 2
        case 5:
            nextGridSize = 5
            nextTimeLimit = 15
            nextRevealTime = 1.0
            nextTargetMatches = 2
        case 6:
            nextGridSize = 5
            nextTimeLimit = 12
            nextRevealTime = 0.8
            nextTargetMatches = 3
        default:
            // Continue with hardest level
            nextGridSize = 5
            nextTimeLimit = max(10, 15 - currentLevel)
            nextRevealTime = max(0.5, 1.0 - Double(currentLevel - 6) * 0.1)
            nextTargetMatches = 3
        }
        
        // Update Level Up mode parameters
        levelUpGridSize = nextGridSize
        levelUpTimeLimit = nextTimeLimit
        levelUpRevealTime = nextRevealTime
        levelUpTargetMatches = nextTargetMatches
        
        timeRemaining = nextTimeLimit
        matchesFound = 0
        totalMatchesInRound = nextTargetMatches
        
        // Show level up message before starting new level
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.score += 50  // Bonus for leveling up
            print("✅ Level Up! Now at Level \(self.currentLevel)")
            self.generateGrid()
            self.revealColorsTemporarily()
        }
    }
    
    func saveScore() {
        guard !playerName.isEmpty else { return }
        
        // NEW! For Level Up mode, save with level info in name
        let displayName = currentMode == .levelUp ? "\(playerName) (Lvl \(currentLevel))" : playerName
        
        let newHighScore = HighScore(
            name: displayName,
            score: score,
            mode: currentMode.rawValue,
            date: Date()
        )
        
        highScores.append(newHighScore)
        highScores.sort { $0.score > $1.score }
        highScores = Array(highScores.prefix(30))
        
        saveHighScores()
        savePlayerName()
        
        // Save to Firebase
        FirebaseManager.shared.saveHighScore(newHighScore) { error in
            if let error = error {
                print("❌ Firebase save error: \(error.localizedDescription)")
            } else {
                print("✅ Score saved to Firebase successfully!")
            }
        }
        
        showNameInput = false
    }
    
    private func isHighScore() -> Bool {
        let modeScores = highScores.filter { $0.mode == currentMode.rawValue }
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
        timer?.invalidate()
        revealTimer?.invalidate()
        hideTimer?.invalidate()
        isRevealing = false
        matchesFound = 0
        showNameInput = false
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
