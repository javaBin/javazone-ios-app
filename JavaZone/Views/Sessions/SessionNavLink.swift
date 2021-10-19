import SwiftUI

struct SessionNavLink: View {
    var session : Session
    var pending = false

    var body: some View {
        NavigationLink(
            destination: SessionDetailView(session: session, pending: pending),
            label: {
                SessionItemView(session: session, pending: pending)
            }
        ).id(session.sessionId ?? UUID().uuidString)
    }
}
