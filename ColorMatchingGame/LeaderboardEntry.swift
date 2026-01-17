//
//  LeaderboardEntry.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-17.
//
import Foundation

struct LeaderboardEntry: Codable, Identifiable, Comparable {
    let id = UUID()
    let playerName: String
    let score: Int
    let time: Int

    static func < (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
        if lhs.score == rhs.score {
            return lhs.time > rhs.time
        }
        return lhs.score < rhs.score
    }
}
