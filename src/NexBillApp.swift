import SwiftUI
import SwiftData

@main
struct NexBillApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
                .modelContainer(for: [Person.self, Bill.self, BillItem.self, NexGroup.self])
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            switch appState.currentScreen {
            case .dashboard:
                DashboardView()
            case .selectPeople:
                SelectPeopleView()
            case .upload:
                BillUploadView()
            case .manualEntry, .editor:
                BillEditorView()
            case .groups:
                GroupsView()
            case .bills:
                BillsView()
            }
        }
        .animation(.easeInOut, value: appState.currentScreen)
        .onAppear {
            appState.modelContext = modelContext
            appState.loadData()
        }
    }
}
