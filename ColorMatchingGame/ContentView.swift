import SwiftUI

struct ContentView: View {
    @State private var selectedMode: GameMode?
    @State private var animateGradient = false

    let modeGradients: [GameMode: [Color]] = [
        .easy: [Color(red: 1.0, green: 0.8, blue: 0.8), Color(red: 1.0, green: 0.6, blue: 0.6)],
        .medium: [Color(red: 0.6, green: 1.0, blue: 0.6), Color(red: 0.4, green: 0.9, blue: 0.4)],
        .hard: [Color(red: 0.6, green: 0.8, blue: 1.0), Color(red: 0.3, green: 0.6, blue: 1.0)]
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: animateGradient ? [.purple.opacity(0.3), .blue.opacity(0.3)] : [.pink.opacity(0.3), .cyan.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 15).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }

                VStack(spacing: 40) {
                    Spacer()

                    VStack(spacing: 8){
                        Text("Chromatic Grid")
                            .font(.system(size:42, weight:.bold))
                            .foregroundColor(.black)
                        Text("A Color Puzzle Game")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 20){
                        ForEach(GameMode.allCases){ mode in
                            Button{
                                selectedMode = mode
                            } label:{
                                HStack{
                                    VStack(alignment:.leading,spacing:4){
                                        Text(mode.title)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Text(mode.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    Spacer()
                                    Image(systemName:"chevron.right").foregroundColor(.white.opacity(0.8))
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: modeGradients[mode] ?? [.gray, .gray.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color:.black.opacity(0.1),radius:8,x:0,y:4)
                            }.buttonStyle(.plain)
                        }
                    }

                    Spacer()
                }.padding()
            }
            .navigationDestination(item: $selectedMode) { mode in GameView(mode: mode) }
        }
    }
}

