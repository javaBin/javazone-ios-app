import SwiftUI
import CoreData

struct SessionItemView: View {
    @ObservedObject var session: Session
    
    var body: some View {
        HStack {
            VStack {
                Text(session.fromTime()).font(.caption)
                Text(session.toTime()).font(.caption)
                if (session.lightningTalk) {
                    Image(systemName: "bolt")
                }
            }
            VStack(alignment: .leading) {
                if (session.title != nil) {
                    Text(session.wrappedTitle).font(.body)
                }
                HStack {
                    if (session.room != nil) {
                        Text(session.wrappedRoom).font(.caption)
                    }
                    Text(session.speakerNames).font(.caption)
                }
            }
            Spacer()
            if (session.notYetStarted()) {
                FavouriteToggleView(favourite: $session.favourite, notificationId: session.sessionId ?? UUID().uuidString, notificationTitle: session.wrappedTitle, notificationLocation: session.wrappedRoom, notificationTrigger: session.startUtc)
            }
            if (session.videoId != nil) {
                Image(systemName: "video")
            }
        }
    }
}

struct SessionItemView_Previews: PreviewProvider {
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
            SessionItemView(session: session)
        }
    }
}
