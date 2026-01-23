// ColorTile.swift
import SwiftUI

struct ColorTile: Identifiable {
    let id = UUID()
    let color: Color
    var isTarget: Bool = false
    var isRevealed: Bool = false
    var isHidden: Bool = false
}
