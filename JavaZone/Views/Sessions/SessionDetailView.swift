import SwiftUI
import CoreData

struct SessionDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @ObservedObject var session: Session

    var pending: Bool

    @State private var showShareSheet = false

    var title: String {
        return pending ? "Room and Time pending" : "\(session.room ?? "") - \(session.fromTime()) - \(session.toTime())"
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    if !pending {
                        FavouriteToggleView(
                            favourite: $session.favourite,
                            notificationId: session.sessionId ?? UUID().uuidString,
                            notificationTitle: session.wrappedTitle,
                            notificationLocation: session.wrappedRoom,
                            notificationTrigger: session.startUtc
                        )
                    }
                    VStack(alignment: .leading) {
                        Text(session.wrappedTitle)
                            .copyable(session.wrappedTitle)
                            .font(.headline)
                        if session.videoId != nil {
                            ExternalLink(title: "View session video", url: session.wrappedVideo!, image: "video")
                        }
                    }.padding(.horizontal)
                }.padding(.top)
                VStack(alignment: .leading) {
                    if session.workshop && session.wrappedRegisterLoc != nil {
                        Text("Workshop").font(.title).padding(.bottom, 15)

                        ExternalLink(title: "Open registration page",
                                     url: session.wrappedRegisterLoc!).padding(.bottom, 15)
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
                    }.padding(.bottom, 15)
                    if session.abstract != nil {
                        Text(session.wrappedAbstract)
                            .font(.body)
                            .copyable(session.wrappedAbstract)
                            .padding(.bottom, 20)
                    }
                    if session.workshopPrerequisites != nil {
                        Text("Prerequisites").font(.title).padding(.bottom, 15)
                        Text(session.wrappedWorkshopPrerequisites)
                            .font(.body)
                            .copyable(session.wrappedWorkshopPrerequisites)
                            .padding(.bottom, 20)
                    }
                    Text("Intended Audience").font(.title).padding(.bottom, 15)
                    if session.audience != nil {
                        Text(session.wrappedAudience).font(.body).padding(.bottom, 20)
                    }
                    Text("Speakers").font(.title).padding(.bottom, 15)
                    ForEach(session.speakerArray, id: \.self) { speaker in
                        SpeakerItemView(speaker: speaker)
                    }
                }.padding()
            }
        }
        .navigationTitle(Text(title))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            self.buildShareSheet()
        }
        .navigationBarItems(trailing: Button(action: {
                self.showShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        )
    }

    func buildShareSheet() -> some View {
        var items: [Any] = []

        if self.session.wrappedTitle != "" {
            items.append(self.session.wrappedTitle)
        }

        if let sessionId = self.session.sessionId {
            items.append(URL(string: "\(Config.sharedConfig.web)program/\(sessionId)")!)
        }

        return ShareSheet(activityItems: items)
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let session = Session(context: moc)

        session.title = "Test Title"
        session.abstract = "This is a test abstract about the talk. I need a longer string to test the preview better"
        session.favourite = false
        session.audience = "Test Audience - suitable for nerds"
        session.startUtc = Date()
        session.endUtc = Date()
        session.room = "Room 1"

        let speaker = Speaker(context: moc)

        speaker.name = "Test speaker"
        speaker.bio = "Test Bio - lots of uninteresting factoids"
        speaker.twitter = "@TestTwitter"
        speaker.session = session

        return NavigationStack {
            SessionDetailView(session: session, pending: false)
        }
    }
}
