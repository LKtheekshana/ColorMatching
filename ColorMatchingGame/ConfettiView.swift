//
//  ConfettiView.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-17.
//
import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    let colors: [Color] = [.red, .green, .blue, .yellow, .pink, .purple, .orange]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for particle in particles {
                    var rect = Path()
                    rect.addRect(CGRect(x: particle.x, y: particle.y, width: particle.size, height: particle.size))
                    context.fill(rect, with: .color(particle.color))
                }
            }
            .onAppear {
                generateParticles(size: geo.size)
                startAnimation(size: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    private func generateParticles(size: CGSize) {
        particles = (0..<100).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -200...0),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 5...12),
                rotation: Double.random(in: 0...360),
                speed: CGFloat.random(in: 2...6)
            )
        }
    }

    private func startAnimation(size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            for i in particles.indices {
                particles[i].y += particles[i].speed
                particles[i].rotation += Double(particles[i].speed * 2)
                if particles[i].y > size.height {
                    particles[i].y = CGFloat.random(in: -50...0)
                    particles[i].x = CGFloat.random(in: 0...size.width)
                    particles[i].color = colors.randomElement()!
                }
            }
        }
    }
}

