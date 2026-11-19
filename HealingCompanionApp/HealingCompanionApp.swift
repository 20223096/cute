import SwiftUI

@main
struct HealingCompanionApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .environmentObject(appState.emotionLog)
                .environmentObject(appState.friendsStore)
                .environmentObject(appState.customEmotionStore)
                .environmentObject(appState.journalStore)
                .environmentObject(appState.comfortStore)
                .environmentObject(appState.letterStore)
                .onAppear {
                    appState.consumePendingReaction()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        appState.consumePendingReaction()
                    }
                }
        }
    }
}
