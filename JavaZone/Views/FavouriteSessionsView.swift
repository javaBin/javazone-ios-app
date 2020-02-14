//

import SwiftUI

struct FavouriteSessionsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getFavourites()) var sessions:FetchedResults<Session>
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.sessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionItemView(session: session)
                    }
                }
            }.navigationBarTitle("My Schedule")
        }
    }
}

struct FavouriteSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteSessionsView()
    }
}
