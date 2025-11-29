import SwiftUI

@main
struct ExpenseTrackerApp: App {
    // Initialize the ViewModel once here to share across the app
    @StateObject var viewModel = ExpenseViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                // Tab 1: Home
                HomeView(viewModel: viewModel)
                    .tabItem {
                        Label("หน้าหลัก", systemImage: "house.fill")
                    }
                
                // Tab 2: Report
                ReportView(viewModel: viewModel)
                    .tabItem {
                        Label("สรุปผล", systemImage: "chart.pie.fill")
                    }
            }
        }
    }
}
