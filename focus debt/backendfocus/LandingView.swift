import SwiftUI

struct LandingView: View {
    @State private var showLogo = false
    @State private var showButton = false
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    Image("FocusDebtLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .scaleEffect(showLogo ? 1 : 0.85)
                        .opacity(showLogo ? 1 : 0)

                    Spacer()

                    Button {
                        showLogin = true
                    } label: {
                        Text("Log in")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.brandBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)
                    .allowsHitTesting(showButton)
                }
                .padding(28)
            }
            .navigationDestination(isPresented: $showLogin) {
                WelcomeView()
            }
            .task { await runIntro() }
        }
    }

    @MainActor
    private func runIntro() async {
        guard !showButton else { return }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
            showLogo = true
        }

        try? await Task.sleep(for: .seconds(1.0))
        withAnimation(.easeOut(duration: 0.5)) { showButton = true }
    }
}

#Preview {
    LandingView()
        .environmentObject(DataManager())
}
