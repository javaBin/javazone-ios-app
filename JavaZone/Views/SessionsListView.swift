import SwiftUI
import SwiftUIRefresh
import CoreData

struct RelevantSessions {
    var sessions: [Session]
    var sections: [String]
    var grouped: [String: [Session]]
}

struct SessionsListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getSessions()) var allSessions: FetchedResults<Session>
    
    var favouritesOnly: Bool
    var title: String
    
    @State private var selectorIndex = 0
    @State private var searchText = ""
    @State private var isShowing = false

    var sessions : RelevantSessions {
        let sessions = self.allSessions
            .filter { (session) -> Bool in
                session.startUtc?.asDate() ?? "" == Config.dates[selectorIndex]
        }
        .filter { (session) -> Bool in
            session.favourite == true || self.favouritesOnly == false
        }
        .filter { (session) -> Bool in
            if (self.searchText == "") {
                return true
            }
            
            return session.wrappedTitle.contains(self.searchText) || session.speakerNames.contains(self.searchText)
        }
        
        let grouped = Dictionary(grouping: sessions, by: { $0.startUtc?.asHour() ?? "00:00" })
        
        let sections = Array(grouped.keys).sorted(by: <)
        
        return RelevantSessions(sessions: sessions, sections: sections, grouped: grouped)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectorIndex) {
                    Text(Config.dates[0]).tag(0)
                    Text(Config.dates[1]).tag(1)
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                
                SearchView(searchText: $searchText)

                List {
                    ForEach(self.sessions.sections, id: \.self) { section in
                        Section(header: Text(section)) {
                            ForEach(self.sessions.grouped[section] ?? [], id: \.self) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionItemView(session: session)
                                }
                            }
                        }
                    }
                }
                .resignKeyboardOnDragGesture()
                .pullToRefresh(isShowing: $isShowing) {
                    SessionService.refresh() {
                        self.isShowing = false
                    }
                }
            }.navigationBarTitle(title)
        }
    }
}

struct SessionListView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        var sessions: [Session] = []
        
        for number in 1...3 {
            let session = Session(context: moc)
            
            session.title = "Test Title \(number)"
            session.abstract = "This is a test abstract about the talk. I need a longer string to test the preview better"
            session.favourite = false
            session.audience = "Test Audience - suitable for nerds"
            session.startUtc = Date()
            session.endUtc = Date()
            session.room = "Room 1"
            
            let speaker = Speaker(context: moc)
            
            speaker.name = "Test speaker \(number)"
            speaker.bio = "Test Bio - lots of uninteresting factoids"
            speaker.twitter = "@TestTwitter\(number)"
            
            session.speakers = [speaker]
            
            sessions.append(session)
        }

        return SessionsListView(favouritesOnly: false, title: "Sessions").environment(\.managedObjectContext, moc)
    }
}
