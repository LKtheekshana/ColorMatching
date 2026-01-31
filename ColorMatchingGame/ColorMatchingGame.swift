import SwiftUI

struct ColorMatchingGame: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showingScoreboard = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray6),
                        Color(.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if !viewModel.isGameStarted {
                    // Modern Mode Selection Screen
                    modernModeSelectionScreen
                } else {
                    // Game Screen
                    modernGameScreen
                }
                
                // Name Input Overlay
                if viewModel.showNameInput {
                    nameInputOverlay
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingScoreboard) {
                ScoreboardView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Name Input Overlay
    
    private var nameInputOverlay: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    // Don't dismiss on background tap
                }
            
            VStack(spacing: 20) {
                // Congratulations Card
                VStack(spacing: 15) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("New High Score!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("\(viewModel.score) points")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("in \(viewModel.currentMode.rawValue) Mode")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)
                
                // Name Input Card
                VStack(spacing: 20) {
                    Text("Enter Your Name")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    TextField("Your Name", text: $viewModel.playerName)
                        .font(.system(size: 18, design: .rounded))
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                        .onSubmit {
                            if !viewModel.playerName.isEmpty {
                                viewModel.saveScore()
                            }
                        }
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            viewModel.playerName = ""
                            viewModel.showNameInput = false
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray5))
                                )
                        }
                        
                        Button(action: {
                            if !viewModel.playerName.isEmpty {
                                viewModel.saveScore()
                            }
                        }) {
                            Text("Save Score")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.playerName.isEmpty ? Color.gray : Color.blue)
                                )
                        }
                        .disabled(viewModel.playerName.isEmpty)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)
            }
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(response: 0.3), value: viewModel.showNameInput)
    }
    
    // MARK: - Modern Mode Selection Screen
    
    private var modernModeSelectionScreen: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Elegant Header
                VStack(spacing: 12) {
                    // Logo/Icon with gradient
                    ZStack {
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [.blue, .purple, .blue]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 8)
                            .opacity(0.6)
                        
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    Text("Color Matching")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Test Your Memory & Speed")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 30)
                
                // Mode Cards
                VStack(spacing: 16) {
                    Text("Select Game Mode")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    // Original Modes
                    ForEach(GameMode.allCases.filter { $0 != .levelUp }, id: \.self) { mode in
                        modernModeCard(mode: mode)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    viewModel.startGame(mode: mode)
                                }
                            }
                    }
                    
                    // NEW! Level Up Mode Card
                    modernLevelUpModeCard()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.startGame(mode: .levelUp)
                            }
                        }
                    
                    // Quick Start Hint
                    Text("Tap any card to begin")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                        .opacity(0.7)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func modernModeCard(mode: GameMode) -> some View {
        VStack(spacing: 0) {
            // Card Header with Icon
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(modeCardGradient(mode).opacity(0.9))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: modeIconName(mode))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Mode Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(modeDescription(mode))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(modePrimaryColor(mode).opacity(0.7))
            }
            .padding(20)
            
            // Card Divider
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Stats Row
            HStack(spacing: 0) {
                statItem(icon: "square.grid.2x2", value: "\(mode.gridSize)×\(mode.gridSize)")
                
                Divider()
                    .frame(height: 20)
                
                statItem(icon: "clock", value: "\(mode.timeLimit)s")
                
                Divider()
                    .frame(height: 20)
                
                statItem(icon: "eye", value: "\(String(format: "%.1f", mode.revealTime))s")
                
                Divider()
                    .frame(height: 20)
                
                statItem(icon: "target", value: "\(mode.targetMatches)×")
            }
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        .shadow(color: modePrimaryColor(mode).opacity(0.05), radius: 30, x: 0, y: 20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // NEW! Level Up Mode Card
    private func modernLevelUpModeCard() -> some View {
        VStack(spacing: 0) {
            // Card Header with Icon
            HStack(spacing: 16) {
                // Icon Container with animated gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1, green: 0.5, blue: 0),
                                    Color(red: 1, green: 0.2, blue: 0),
                                    Color(red: 1, green: 0.5, blue: 0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Mode Info
                VStack(alignment: .leading, spacing: 6) {
                    Text("Level Up")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Progressive difficulty")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    Text("NEW!")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            .padding(20)
            
            // Card Divider
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            // Stats Row
            HStack(spacing: 0) {
                statItem(icon: "1.circle.fill", value: "Start\nEasy")
                
                Divider()
                    .frame(height: 20)
                
                statItem(icon: "5.circle.fill", value: "Grow\nGrid")
                
                Divider()
                    .frame(height: 20)
                
                statItem(icon: "bolt.fill", value: "Speed\nUp")
                
                Divider()
                    .frame(height: 20)
                
                statItem(icon: "target", value: "More\nMatches")
            }
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1, green: 0.5, blue: 0).opacity(0.05),
                        Color(red: 1, green: 0.2, blue: 0).opacity(0.05)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.orange.opacity(0.15), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.2), lineWidth: 2)
        )
    }
    
    // MARK: - Modern Game Screen
    
    private var modernGameScreen: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Game Header
                VStack(spacing: 4) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.endGame()
                                viewModel.isGameStarted = false
                            }
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("Color Match")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingScoreboard = true
                        }) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Text("Memory Challenge")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Score, Timer, and Matches
                HStack(spacing: 12) {
                    scoreView
                    
                    matchesProgressView
                    
                    Spacer()
                    
                    timerView
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Target Color Display
                VStack(spacing: 12) {
                    Text("Find \(viewModel.currentMode.targetMatches) color\(viewModel.currentMode.targetMatches > 1 ? "s" : "")")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    ZStack {
                        Circle()
                            .fill(viewModel.targetColor)
                            .frame(width: 100, height: 100)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                        
                        if !viewModel.isGameActive {
                            Image(systemName: "questionmark")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                // Game Status
                Group {
                    if !viewModel.gameResult.isEmpty {
                        Text(viewModel.gameResult)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                    } else if viewModel.isRevealing {
                        VStack(spacing: 8) {
                            Text("Memorize Colors (\(String(format: "%.1f", viewModel.currentMode.revealTime))s)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.orange)
                            
                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [.green, .blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(width: geo.size.width * CGFloat(viewModel.revealProgress), height: 8)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal, 40)
                        }
                    } else {
                        // NEW! Level Up mode display
                        if viewModel.currentMode == .levelUp {
                            VStack(spacing: 4) {
                                Text("LEVEL \(viewModel.currentLevel)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                
                                Text("Round \(viewModel.roundNumber)")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            VStack(spacing: 4) {
                                Text("Round \(viewModel.roundNumber)")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(.gray)
                                
                                if viewModel.currentMode.targetMatches > 1 {
                                    Text("Find \(viewModel.currentMode.targetMatches) matches")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .frame(height: 50)
                .padding(.bottom, 10)
                
                // Color Grid
                modernGridView(screenWidth: geometry.size.width)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                
                // Instructions
                if viewModel.currentMode.targetMatches > 1 {
                    Text(viewModel.isRevealing ?
                         "Memorize all \(viewModel.currentMode.targetMatches) matching colors!" :
                         "Find \(viewModel.currentMode.targetMatches) matching colors")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                } else {
                    Text(viewModel.isRevealing ?
                         "Memorize the colors quickly!" :
                         "Tap to find the matching color")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                
                Spacer()
            }
        }
    }
    
    private var scoreView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18))
                Text("SCORE")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Text("\(viewModel.score)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    private var matchesProgressView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 18))
                Text("MATCHES")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Text("\(viewModel.matchesFound)/\(viewModel.totalMatchesInRound)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    private var timerView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .foregroundColor(timeColor)
                    .font(.system(size: 18))
                Text("TIME")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Text("\(viewModel.timeRemaining)s")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(timeColor)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    private var timeColor: Color {
        if viewModel.timeRemaining <= 10 {
            return .red
        } else if viewModel.timeRemaining <= 20 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func modernGridView(screenWidth: CGFloat) -> some View {
        let maxGridWidth = min(screenWidth - 32, 380)
        let gridSize = viewModel.currentMode.gridSize
        let spacing: CGFloat = gridSize >= 5 ? 6 : 8
        let availableWidth = maxGridWidth - 24
        let tileSize = (availableWidth - CGFloat(gridSize - 1) * spacing) / CGFloat(gridSize)
        
        let columns = Array(repeating: GridItem(.fixed(tileSize), spacing: spacing), count: gridSize)
        
        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(viewModel.tiles) { tile in
                modernTileView(tile, size: tileSize)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
    
    private func modernTileView(_ tile: ColorTile, size: CGFloat) -> some View {
        Button(action: {
            guard viewModel.isGameActive && !viewModel.isRevealing else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.tileTapped(tile)
            }
        }) {
            ZStack {
                // Hidden state (question mark)
                if !tile.isRevealed && tile.isHidden {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: size, height: size)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }
                // Revealed state (actual color) - Thicker border for matching tiles
                else if tile.isRevealed {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tile.color)
                        .frame(width: size, height: size)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.white,
                                    lineWidth: tile.color == viewModel.targetColor && tile.isRevealed ? 4 : 2
                                )
                        )
                }
                // Flipping animation state
                else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: size, height: size)
                }
            }
        }
        .buttonStyle(ModernTileButtonStyle())
        .disabled(viewModel.isRevealing || !viewModel.isGameActive)
    }
    
    private func statItem(icon: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .frame(height: 14)
            
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Color and Style Helpers
    
    private func modeCardGradient(_ mode: GameMode) -> LinearGradient {
        switch mode {
        case .easy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.9, blue: 0.4),
                    Color(red: 0.1, green: 0.7, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .medium:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1, green: 0.6, blue: 0.3),
                    Color(red: 1, green: 0.4, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hard:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1, green: 0.3, blue: 0.3),
                    Color(red: 0.8, green: 0.2, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .levelUp:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1, green: 0.5, blue: 0),
                    Color(red: 1, green: 0.2, blue: 0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func modeCardShadowColor(_ mode: GameMode) -> Color {
        switch mode {
        case .easy:
            return Color.green.opacity(0.3)
        case .medium:
            return Color.orange.opacity(0.3)
        case .hard:
            return Color.red.opacity(0.3)
        case .levelUp:
            return Color.orange.opacity(0.3)
        }
    }
    
    private func modeIconName(_ mode: GameMode) -> String {
        switch mode {
        case .easy:
            return "leaf.fill"
        case .medium:
            return "flame.fill"
        case .hard:
            return "bolt.fill"
        case .levelUp:
            return "arrow.up.circle.fill"
        }
    }
    
    private func modePrimaryColor(_ mode: GameMode) -> Color {
        switch mode {
        case .easy:
            return Color.green
        case .medium:
            return Color.orange
        case .hard:
            return Color.red
        case .levelUp:
            return Color.orange
        }
    }
    
    private func modeDescription(_ mode: GameMode) -> String {
        switch mode {
        case .easy:
            return "Perfect for beginners"
        case .medium:
            return "Balanced challenge"
        case .hard:
            return "For memory masters"
        case .levelUp:
            return "Progressive difficulty"
        }
    }
}

// MARK: - Button Styles

struct ModernTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    ColorMatchingGame()
}
