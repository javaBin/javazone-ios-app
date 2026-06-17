import SwiftUI
import SwiftData

struct SessionDetailView: View {
    var session: Session
    @Environment(AppConfig.self) private var appConfig
    var pending: Bool

    @Query private var bodies: [SessionBody]
    private var content: SessionBody? { bodies.first }

    init(session: Session, pending: Bool) {
        self.session = session
        self.pending = pending
        let id = session.sessionId ?? ""
        self._bodies = Query(filter: #Predicate<SessionBody> { $0.sessionId == id })
    }

    var title: String {
        pending ? "Room and Time pending" : "\(session.wrappedRoom) - \(session.fromTime()) - \(session.toTime())"
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    if !pending {
                        FavouriteToggleView(session: session)
                    }
                    VStack(alignment: .leading) {
                        Text(session.wrappedTitle)
                            .textSelection(.enabled)
                            .font(.headline)
                        if session.videoId != nil, let videoUrl = session.wrappedVideo {
                            ExternalLink(title: "View session video", url: videoUrl, image: "video")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)

                VStack(alignment: .leading) {
                    if session.workshop, let registerLoc = session.wrappedRegisterLoc {
                        Text("Workshop").font(.title).padding(.bottom, 15)
                        ExternalLink(title: "Open registration page", url: registerLoc).padding(.bottom, 15)
                    }
                    HStack {
                        Text("Abstract").font(.title)
                        if session.lightningTalk {
                            Spacer()
                            Image(systemName: "bolt")
                                .accessibilityLabel("Lightning talk")
                        }
                        if session.workshop {
                            Spacer()
                            Image(systemName: "laptopcomputer")
                                .accessibilityLabel("Workshop")
                        }
                    }
                    .padding(.bottom, 15)

                    if let content {
                        if content.abstract != nil {
                            Text(content.wrappedAbstract)
                                .font(.body)
                                .textSelection(.enabled)
                                .padding(.bottom, 20)
                        }
                        if content.workshopPrerequisites != nil {
                            Text("Prerequisites").font(.title).padding(.bottom, 15)
                            Text(content.wrappedWorkshopPrerequisites)
                                .font(.body)
                                .textSelection(.enabled)
                                .padding(.bottom, 20)
                        }
                        Text("Intended Audience").font(.title).padding(.bottom, 15)
                        if content.audience != nil {
                            Text(content.wrappedAudience).font(.body).padding(.bottom, 20)
                        }
                        Text("Speakers").font(.title).padding(.bottom, 15)
                        ForEach(content.speakerArray, id: \.persistentModelID) { speaker in
                            SpeakerItemView(speaker: speaker)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding()
            }
        }
        .navigationTitle(Text(title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let sessionId = session.sessionId,
               let url = URL(string: "\(appConfig.web)program/\(sessionId)") {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url, subject: Text(session.wrappedTitle))
                }
            }
        }
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Session.self, SessionBody.self, Speaker.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let session = Session(
        title: "Test Title", room: "Room 1",
        startUtc: Date(), endUtc: Date(),
        favourite: false, sessionId: "test-1"
    )
    container.mainContext.insert(session)
    let body = SessionBody(sessionId: "test-1", abstract: "Test abstract", audience: "All levels")
    container.mainContext.insert(body)
    container.mainContext.insert(Speaker(name: "Alice", body: body))
    return NavigationStack {
        SessionDetailView(session: session, pending: false)
    }
    .modelContainer(container)
    .environment(AppConfig())
}
