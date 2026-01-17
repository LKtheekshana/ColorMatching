//
//  LeaderboardView.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-17.
//
import SwiftUI

struct LeaderboardView: View {
    let mode: GameMode
    @State private var entries:[LeaderboardEntry]=[]

    var body: some View {
        VStack{
            Text("\(mode.title) Leaderboard").font(.largeTitle).fontWeight(.bold).padding()
            List(entries){ entry in
                HStack{
                    Text(entry.playerName)
                    Spacer()
                    Text("Score: \(entry.score)")
                    Text("Time: \(formatTime(entry.time))").foregroundColor(.gray).font(.subheadline)
                }
            }
            Button("Reset Leaderboard"){ LeaderboardManager.shared.reset(for:mode.title); loadLeaderboard() }
                .foregroundColor(.red).padding()
        }.onAppear{ loadLeaderboard() }
    }

    private func loadLeaderboard(){ entries=LeaderboardManager.shared.load(for:mode.title) }
    private func formatTime(_ seconds:Int)->String{ String(format:"%02d:%02d",seconds/60,seconds%60) }
}

