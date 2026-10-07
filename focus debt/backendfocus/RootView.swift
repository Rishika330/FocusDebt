import SwiftUI

struct RootView: View {
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        Group {
            if dataManager.isLoggedIn {
                DashboardView() // Replace this with the exact name of your main dashboard view
            } else {
                LandingView()
            }
        }
    }
}
