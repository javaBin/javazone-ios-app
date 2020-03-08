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
                #if DEBUG
                PartnersView()
                    .font(.title)
                    .tabItem {
                        VStack {
                            Image(systemName: "qrcode")
                            Text("Partners")
                        }
                    }
                    .tag(3)
                #endif
            }
            
            if (blockingRefresh) {
                SpinnerView()
            }
        }
    }
}
