import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "heart.fill")
                }

            EmotionCalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "book.closed.fill")
                }

            FriendsFeedView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
        }
        .tint(Color(red: 0.95, green: 0.5, blue: 0.6))
    }
}
