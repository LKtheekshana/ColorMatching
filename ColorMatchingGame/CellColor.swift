//
//  CellColor.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-16.
//
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
        let all = CellColor.allCases
        let index = all.firstIndex(of: self)!
        return all[(index+1) % all.count]
    }

    var isPlayableColor: Bool { self != .gray }
    static var playableColors: [CellColor] { [.red,.green,.blue,.yellow] }
}


