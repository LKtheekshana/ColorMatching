//
//  GameMode.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-16.
//
import Foundation

enum GameMode: Int, Identifiable, CaseIterable {
    case easy = 3, medium = 4, hard = 5

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }

    var subtitle: String { "\(rawValue) x \(rawValue) Grid" }
    var gridSize: Int { rawValue }
}

