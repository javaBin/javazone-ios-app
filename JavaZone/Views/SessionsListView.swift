import SwiftUI
import SwiftUIRefresh
import CoreData

class SectionTitle : Identifiable {
    var title : String
    
    init(title: String) {
        self.title = title
    }
}

struct SessionsListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var favouritesOnly: Bool
    var title: String
    
    @State private var selectorIndex = 0
    @State private var searchText = ""
    @State private var isShowing = false
    
    var sessions : [Session] {
        do {
            return try self.managedObjectContext.fetch(Session.getSessions(favouritesOnly: favouritesOnly, searchText: searchText))
        } catch {
            print("Could not fetch")
        }
        return []
    }
    
    var sessionsOnDate : [Session] {
        self.sessions.filter { (session) -> Bool in
            if let start = session.startUtc?.asDate() {
                return start == Config.dates[selectorIndex]
            } else {
                return false    
            }
        }
    }
    
    var sessionsOnDateByHour : [String: [Session]] {
        return Dictionary(grouping: sessions, by: { $0.startUtc?.asHour() ?? "00:00" })
    }
    
    var sections : [SectionTitle] {
        return Array(sessionsOnDateByHour.keys).sorted(by: <).map {SectionTitle(title: $0) }
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
                    ForEach(self.sections) { section in
                        Section(header: Text(section.title)) {
                            ForEach(self.sessionsOnDateByHour[section.title] ?? [], id: \.self) { session in
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
                    
                    /*
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // After a timeout - clear if still present? Error if nothing fetched?
                        self.isShowing = false
                    }
 */
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
