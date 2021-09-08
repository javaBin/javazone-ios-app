import SwiftUI

struct SessionNavLink: View {
    var session : Session

    var body: some View {
        NavigationLink(
            destination: SessionDetailView(session: session),
            label: {
                SessionItemView(session: session)
            }
        ).id(session.sessionId ?? UUID().uuidString)
    }
}
