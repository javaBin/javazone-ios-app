import SwiftUI

struct SessionNavLink: View {
    var session: Session
    var pending: Bool

    var body: some View {
        NavigationLink(value: SessionWithPending(sessionId: session.sessionId ?? "", pending: pending)) {
            SessionItemView(session: session, pending: pending)
        }
        .id(session.persistentModelID)
    }
}
