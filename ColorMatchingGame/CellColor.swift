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
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        case .gray: return .gray.opacity(0.4)
        }
    }

    func next() -> CellColor {
        let all = CellColor.allCases
        let index = all.firstIndex(of: self)!
        return all[(index + 1) % all.count]
    }

    var isPlayableColor: Bool {
        self != .gray
    }
}
