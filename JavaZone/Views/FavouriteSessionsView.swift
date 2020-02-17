import SwiftUI

struct FavouriteSessionsView: View {
    var body: some View {
        SessionsListView(favouritesOnly: true, title: "My Schedule")
    }
}
