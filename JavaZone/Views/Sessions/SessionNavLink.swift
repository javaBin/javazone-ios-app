import SwiftUI

struct SessionNavLink: View {
    var sessionWithPending : SessionWithPending

    var body: some View {
        NavigationLink(value: sessionWithPending) {
            SessionItemView(session: sessionWithPending.session, pending: sessionWithPending.pending)
        }.id(sessionWithPending.session.sessionId ?? UUID().uuidString)
    }
}


