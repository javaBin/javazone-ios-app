import SwiftUI
import Flurry_iOS_SDK

struct SessionsView: View {
    @Binding var blockingRefresh : Bool
    
    var body: some View {
        SessionsListView(blockingRefresh: $blockingRefresh, favouritesOnly: false, title: "Sessions")
            .onAppear {
                Flurry.log(eventName: "ScreenView_Sessions")
            }

    }
}
