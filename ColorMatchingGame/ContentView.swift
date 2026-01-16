//
//  ContentView.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-10.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedMode: GameMode?
    @State private var animateGradient = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Gradient Background
                LinearGradient(
                    colors: animateGradient ? [.purple, .blue, .pink] : [.blue, .purple, .cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

                VStack(spacing: 32) {
                    Spacer()

                    // Game Title
                    VStack(spacing: 8) {
                        Text("Chromatic Grid")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)

                        Text("A Color Puzzle Game")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    // Difficulty Buttons
                    VStack(spacing: 16) {
                        modeButton(.easy)
                        modeButton(.medium)
                        modeButton(.hard)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationDestination(item: $selectedMode) { mode in
                GameView(mode: mode)
            }
        }
    }

    // MARK: - Mode Button
    func modeButton(_ mode: GameMode) -> some View {
        Button {
            selectedMode = mode
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(mode.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}
