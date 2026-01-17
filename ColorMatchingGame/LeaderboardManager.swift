//
//  LeaderboardManager.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-17.
//
import Foundation

final class LeaderboardManager {
    static let shared = LeaderboardManager()
    private init() {}

    func save(entry: LeaderboardEntry, for mode: String) {
        var entries = load(for: mode)
        entries.append(entry)
        entries.sort(by: >)
        if entries.count > 10 { entries.removeLast() }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: "Leaderboard_\(mode)")
        }
    }

    func load(for mode: String) -> [LeaderboardEntry] {
        guard let data = UserDefaults.standard.data(forKey: "Leaderboard_\(mode)"),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func reset(for mode: String) {
        UserDefaults.standard.removeObject(forKey: "Leaderboard_\(mode)")
    }
}
