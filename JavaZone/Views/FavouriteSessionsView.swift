//

import SwiftUI

struct FavouriteSessionsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getFavourites()) var sessions:FetchedResults<Session>

    
    var body: some View {
        List {
            ForEach(self.sessions) { session in
                SessionItemView(session: session)
            }
        }
    }
}

struct FavouriteSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteSessionsView()
    }
}
