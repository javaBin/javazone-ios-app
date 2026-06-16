import SwiftUI
import SwiftData

struct SessionDetailView: View {
    var session: Session
    @Environment(AppConfig.self) private var appConfig
    var pending: Bool

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
                        }
                        if session.workshop {
                            Spacer()
                            Image(systemName: "laptopcomputer")
                        }
                    }
                    .padding(.bottom, 15)
                    if session.abstract != nil {
                        Text(session.wrappedAbstract)
                            .font(.body)
                            .textSelection(.enabled)
                            .padding(.bottom, 20)
                    }
                    if session.workshopPrerequisites != nil {
                        Text("Prerequisites").font(.title).padding(.bottom, 15)
                        Text(session.workshopPrerequisites.val())
                            .font(.body)
                            .textSelection(.enabled)
                            .padding(.bottom, 20)
                    }
                    Text("Intended Audience").font(.title).padding(.bottom, 15)
                    if session.audience != nil {
                        Text(session.wrappedAudience).font(.body).padding(.bottom, 20)
                    }
                    Text("Speakers").font(.title).padding(.bottom, 15)
                    ForEach(session.speakerArray, id: \.persistentModelID) { speaker in
                        SpeakerItemView(speaker: speaker)
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
    let container = try! ModelContainer(for: Session.self, Speaker.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let session = Session(title: "Test Title", abstract: "Test abstract", room: "Room 1", startUtc: Date(), endUtc: Date(), favourite: false, sessionId: "test-1")
    NavigationStack {
        SessionDetailView(session: session, pending: false)
    }
    .modelContainer(container)
    .environment(AppConfig())
}
