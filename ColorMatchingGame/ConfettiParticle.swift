//
//  ConfettiParticle.swift
//  ColorMatchingGame
//
//  Created by COBSCCOMP242P-031 on 2026-01-17.
//
import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var speed: CGFloat
}
