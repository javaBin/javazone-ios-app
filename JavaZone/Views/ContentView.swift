import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @State private var blockingRefresh = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selection){
                SessionsView(blockingRefresh: $blockingRefresh)
                    .tabItem {
                        VStack {
                            Image(systemName: "calendar")
                            Text("Sessions")
                        }
                    }
                    .tag(0)
                FavouriteSessionsView(blockingRefresh: $blockingRefresh)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.crop.circle")
                            Text("My Schedule")
                        }
                    }
                    .tag(1)
                InfoView()
                    .tabItem {
                        VStack {
                            Image(systemName: "info.circle.fill")
                            Text("Info")
                        }
                    }
                    .tag(2)
                PartnerListView()
                    .font(.title)
                    .tabItem {
                        VStack {
                            Image(systemName: "person.3.fill")
                            Text("Partners")
                        }
                    }
                    .tag(3)
            }
            .onChange(of: selection, perform: { [selection] newSelection in
                // Open link for partners and return to whatever was the previous tab
                if (newSelection == 3) {
                    self.selection = selection

                    ConfigService.refreshConfig() {
                        let config = Config.sharedConfig
                        
                        UIApplication.shared.open(URL(string:"\(config.web)partners")!)
                    }
                }
            })
            .onAppear {
                if #available(iOS 15.0, *) {
                    let appearance = UITabBarAppearance()
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            
            if (blockingRefresh) {
                ProgressView("Refreshing sessions")
            }
        }
    }
}
