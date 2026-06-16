import SwiftUI
import SwiftData

struct SessionItemView: View {
    var session: Session
    var pending: Bool

    var body: some View {
        HStack {
            VStack {
                if !pending {
                    Text(session.fromTime()).font(.caption)
                    Text(session.toTime()).font(.caption)
                }
                if session.lightningTalk {
                    Image(systemName: "bolt")
                }
                if session.workshop {
                    Image(systemName: "laptopcomputer")
                }
            }
            VStack(alignment: .leading) {
                if session.title != nil {
                    Text(session.wrappedTitle).font(.body)
                }
                HStack {
                    if !pending && session.room != nil {
                        Text(session.wrappedRoom).font(.caption)
                    }
                    Text(session.speakerNames).font(.caption)
                }
            }
            Spacer()
            if !pending {
                if session.notYetStarted() {
                    FavouriteToggleView(session: session)
                }
                if session.videoId != nil {
                    Image(systemName: "video")
                }
            }
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Session.self, Speaker.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let session = Session(
        title: "Test Title", abstract: "Test abstract",
        format: "presentation", room: "Room 1",
        startUtc: Date(), endUtc: Date(),
        favourite: false, sessionId: "test-1"
    )
    NavigationStack {
        SessionItemView(session: session, pending: false)
    }
    .modelContainer(container)
}
