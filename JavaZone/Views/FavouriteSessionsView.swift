import SwiftUI

struct FavouriteSessionsView: View {
    @FetchRequest(fetchRequest: Session.getFavourites()) var sessions:FetchedResults<Session>
    
    var body: some View {
        SessionsListView(sessions: sessions, title: "My Schedule")
    }
}
