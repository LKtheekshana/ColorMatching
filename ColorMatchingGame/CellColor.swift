import SwiftUI

enum CellColor: CaseIterable, Equatable {
    case red, green, blue, yellow, gray

    var color: Color {
        switch self {
        case .red: return Color(red: 1.0, green: 0.6, blue: 0.6)
        case .green: return Color(red: 0.6, green: 1.0, blue: 0.6)
        case .blue: return Color(red: 0.6, green: 0.8, blue: 1.0)
        case .yellow: return Color(red: 1.0, green: 0.95, blue: 0.6)
        case .gray: return Color.gray.opacity(0.2)
        }
    }

    func next() -> CellColor {
        // Only playable colors should be in the rotation cycle
        let playableColors = CellColor.playableColors
        
        // If current color is gray, start with the first playable color
        if self == .gray {
            return playableColors.first! // Returns red
        }
        
        // If current color is a playable color, find next in playable cycle
        if let currentIndex = playableColors.firstIndex(of: self) {
            let nextIndex = (currentIndex + 1) % playableColors.count
            return playableColors[nextIndex]
        }
        
        // Fallback (should not happen)
        return .red
    }

    var isPlayableColor: Bool { self != .gray }
    static var playableColors: [CellColor] { [.red, .green, .blue, .yellow] }
    
    // Add description for win message
    var description: String {
        switch self {
        case .red: return "Red"
        case .green: return "Green"
        case .blue: return "Blue"
        case .yellow: return "Yellow"
        case .gray: return "Gray"
        }
    }
}
