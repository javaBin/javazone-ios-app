import SwiftUI
import RemoteImage
import CoreData

struct SessionDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var session: Session
    
    var title: String {
        return "\(session.room ?? "") - \(session.fromTime()) - \(session.toTime())"
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack{
                    FavouriteToggleView(favourite: $session.favourite)
                    Text(session.wrappedTitle).font(.headline).padding(.horizontal)
                }.padding(.top)
                VStack(alignment: .leading) {
                    Text("Abstract").font(.title).padding(.bottom, 15)
                    if (session.abstract != nil) {
                        Text(session.wrappedAbstract).font(.body).padding(.bottom, 20)
                    }
                    Text("Intended Audience").font(.title).padding(.bottom, 15)
                    if (session.audience != nil) {
                        Text(session.wrappedAudience).font(.body).padding(.bottom, 20)
                    }
                    Text("Speakers").font(.title).padding(.bottom, 15)
                    ForEach(session.speakerArray, id: \.self) { speaker in
                        VStack(alignment: .leading) {
                            HStack {
                                if (speaker.wrappedAvatar != nil) {
                                    RemoteImage(type: .url(speaker.wrappedAvatar!), errorView: { error in
                                        Image(systemName: "person")
                                    }, imageView: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32.0, height: 32.0)
                                    }, loadingView: {
                                        Image(systemName: "person")
                                    })
                                }
                                Text(speaker.wrappedName).font(.headline).padding(.bottom, 15)
                            }
                            if (speaker.bio != nil) {
                                Text(speaker.wrappedBio).font(.body).padding(.bottom, 15)
                            }
                        }
                    }
                }.padding()
            }
        }
        .navigationBarTitle(Text(title), displayMode: .inline)
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
        
        return NavigationView {
            SessionDetailView(session: session)
        }
    }
}
