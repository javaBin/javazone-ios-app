import SwiftUI

struct ContentView: View {
    @Environment(SessionsViewModel.self) private var sessionsViewModel
    @Environment(AppConfig.self) private var appConfig
    @Environment(\.openURL) private var openURL

    @State private var selection = 0

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                SessionsView()
                    .tabItem { Label("Sessions", systemImage: "calendar") }
                    .tag(0)
                FavouriteSessionsView()
                    .tabItem { Label("My Schedule", systemImage: "person.crop.circle") }
                    .tag(1)
                InfoView()
                    .tabItem { Label("Info", systemImage: "info.circle.fill") }
                    .tag(2)
                // Tag 3 is never actually shown — tapping it opens Safari directly
                Color.clear
                    .tabItem { Label("Partners", systemImage: "person.3.fill") }
                    .tag(3)
            }
            .onChange(of: selection) { previous, new in
                if new == 3 {
                    openURL(appConfig.partnerUrl)
                    selection = previous
                }
            }

            if sessionsViewModel.isRefreshing {
                ProgressView("Refreshing sessions")
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(SessionsViewModel())
        .environment(AppConfig())
        .environment(NotificationRouter())
}
