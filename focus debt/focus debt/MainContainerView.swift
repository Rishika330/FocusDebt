import SwiftUI

struct MainContainerView<Content: View>: View {
    @EnvironmentObject var dataManager: DataManager
    @ViewBuilder let content: Content
    
    @State private var showMenu = false

    var body: some View {
        // Wrap everything in a NavigationStack so NavigationLinks work properly
        NavigationStack {
            ZStack(alignment: .leading) {
                // Main App Content with Custom Header
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            withAnimation(.spring()) {
                                showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        Text("Focus Debt")
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .overlay(Divider(), alignment: .bottom)

                    content
                }
                .disabled(showMenu)
                .blur(radius: showMenu ? 3 : 0)

                // Hamburger Sidebar Overlay
                if showMenu {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showMenu = false
                            }
                        }

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dataManager.student.name.isEmpty ? "Student" : dataManager.student.name)
                                .font(.headline)
                            Text(dataManager.currentEmail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)

                        Divider()

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("Settings", systemImage: "gear")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }

                        Button(role: .destructive) {
                            showMenu = false
                            dataManager.logOut()
                        } label: {
                            Label("Log Out", systemImage: "arrow.turn.left.up")
                                .font(.subheadline)
                        }

                        Spacer()
                    }
                    .padding(20)
                    .frame(width: 260)
                    .background(Color(.systemBackground))
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))
                }
            }
        }
    }
}
