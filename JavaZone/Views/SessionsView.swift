import SwiftUI

struct SessionsView: View {
    @FetchRequest(fetchRequest: Session.getAll()) var sessions:FetchedResults<Session>
    
    var body: some View {
        SessionsListView(sessions: sessions, title: "Sessions")
    }
}
