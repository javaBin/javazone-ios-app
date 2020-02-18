import SwiftUI
import CoreData

struct ItemRatingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var session: Session
    
    // TODO https://github.com/javaBin/javazone-ios-app/issues/8
    @State private var rating1 = 3
    @State private var rating2 = 2
    @State private var rating3 = 5
    @State private var rating4 = 1
    @State private var comments = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Overall")
                        Spacer()
                        RatingView(rating: $rating1)
                    }
                }
                Section {
                    HStack {
                        Text("Relevance")
                        Spacer()
                        RatingView(rating: $rating2)
                    }
                }
                Section {
                    HStack {
                        Text("Content")
                        Spacer()
                        RatingView(rating: $rating3)
                    }
                }
                Section {
                    HStack {
                        Text("Quality")
                        Spacer()
                        RatingView(rating: $rating4)
                    }
                }
                Section {
                    // TODO Currently doesn't support multiline - either have to embed UITextView or wait until WWDC 2020 to see :)
                    TextField("Comments", text: $comments)
                }
            }
            .navigationBarTitle(Text("Feedback"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct ItemRatingView_Previews: PreviewProvider {
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
            ItemRatingView(session: session)
        }
    }
}
