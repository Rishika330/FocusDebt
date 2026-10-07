import SwiftUI

@main
struct FocusDebtApp: App {
    @StateObject private var dataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if dataManager.isLoggedIn {
                    DashboardView() // Replace with your actual main dashboard/tab view name
                } else {
                    LandingView() // This is your login/landing page
                }
            }
            .environmentObject(dataManager)
            .preferredColorScheme(.light)
        }
    }
}
