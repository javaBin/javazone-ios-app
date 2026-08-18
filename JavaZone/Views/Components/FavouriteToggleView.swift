import SwiftUI
import SwiftData
import UserNotifications

struct FavouriteToggleView: View {
    var session: Session

    var body: some View {
        Button(action: toggle) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30.0, height: 30.0)
        }
        .accessibilityLabel(session.favourite ? "Remove from favourites" : "Add to favourites")
        .accessibilityHint(session.favourite ? "Removes this session from your schedule" :
                               "Adds this session to your schedule")
        .accessibilityIdentifier(session.favourite ? "remove-from-favourites" : "add-to-favourites")
    }

    private var imageName: String {
        session.favourite
            ? "person.crop.circle.fill.badge.checkmark"
            : "person.crop.circle.badge.plus"
    }

    private func toggle() {
        session.favourite.toggle()

        // Read everything off the model up front — the Task must not touch a SwiftData
        // object that a refresh could delete underneath it.
        let isFavourite = session.favourite
        guard let sessionId = session.sessionId else { return }
        let reminder = session.startUtc.map {
            NotificationScheduler.Reminder(
                sessionId: sessionId,
                title: session.wrappedTitle,
                room: session.wrappedRoom,
                start: $0
            )
        }

        Task {
            guard isFavourite, let reminder else {
                NotificationScheduler.cancel(sessionId: sessionId)
                return
            }
            guard await NotificationScheduler.requestAuthorization() else { return }
            await NotificationScheduler.schedule(reminder)
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Session.self, SessionBody.self, Speaker.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let session = Session(title: "Test", favourite: false, sessionId: "test-1")
    FavouriteToggleView(session: session)
        .modelContainer(container)
}
