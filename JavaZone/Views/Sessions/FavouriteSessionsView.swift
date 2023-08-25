import SwiftUI
import Flurry_iOS_SDK

struct FavouriteSessionsView: View {
    @Binding var blockingRefresh : Bool

    var body: some View {
        SessionsListView(blockingRefresh: $blockingRefresh, favouritesOnly: true, title: "My Schedule")
            .onAppear {
                Flurry.log(eventName: "ScreenView_FavouriteSessions")
            }

    }
}
