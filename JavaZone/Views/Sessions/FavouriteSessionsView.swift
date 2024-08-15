import SwiftUI

struct FavouriteSessionsView: View {
    @Binding var blockingRefresh : Bool

    var body: some View {
        SessionsListView(blockingRefresh: $blockingRefresh, favouritesOnly: true, title: "My Schedule")
    }
}
