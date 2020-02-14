import SwiftUI

struct SessionsView: View {
    @FetchRequest(fetchRequest: Session.getAll()) var sessions:FetchedResults<Session>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.sessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionItemView(session: session)
                    }
                }
            }.navigationBarTitle("Sessions")
        }
    }
}
