//

import SwiftUI

struct SessionsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getAll()) var sessions:FetchedResults<Session>

    var body: some View {
        List {
            ForEach(self.sessions) { session in
                SessionItemView(session: session)
            }
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
    }
}
