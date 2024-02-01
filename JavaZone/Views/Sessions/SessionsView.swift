import SwiftUI

struct SessionsView: View {
    @Binding var blockingRefresh: Bool

    var body: some View {
        SessionsListView(blockingRefresh: $blockingRefresh, favouritesOnly: false, title: "Sessions")
    }
}
