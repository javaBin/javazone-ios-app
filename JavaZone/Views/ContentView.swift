import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            SessionsView()
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("Sessions")
                    }
                }
                .tag(0)
            FavouriteSessionsView()
                .tabItem {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("My Schedule")
                    }
                }
                .tag(1)
            TestingView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Debug")
                    }
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
