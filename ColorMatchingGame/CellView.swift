import SwiftUI

struct CellView: View {
    let color: Color
    let size: CGFloat
    let isTapped: Bool
    let isHint: Bool
    let isWon: Bool
    var tapAction: () -> Void

    @State private var animateRipple = false
    @State private var animateHint = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

            if animateRipple {
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .frame(width: size * 0.8, height: size * 0.8)
                    .scaleEffect(animateRipple ? 1.5 : 0.1)
                    .opacity(animateRipple ? 0 : 1)
                    .animation(.easeOut(duration: 0.4), value: animateRipple)
            }

            if isHint {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow, lineWidth: 4)
                    .scaleEffect(animateHint ? 1.1 : 1)
                    .opacity(0.7)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { animateHint.toggle() }
                    }
            }

            if isWon {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.6), lineWidth: 4)
                    .shadow(color: Color.green.opacity(0.5), radius: 6)
            }
        }
        .scaleEffect(isTapped ? 1.05 : 1)
        .animation(.spring(response:0.3,dampingFraction:0.6), value: isTapped)
        .onTapGesture {
            animateRipple = true
            tapAction()
            DispatchQueue.main.asyncAfter(deadline:.now()+0.4){ animateRipple = false }
        }
    }
}

