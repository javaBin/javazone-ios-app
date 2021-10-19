import SwiftUI
import SwiftUIRefresh
import CoreData
import os.log

struct RelevantSessions : Equatable {
    var sessions: [Session]
    var sections: [String]
    var grouped: [String: [Session]]
    var pending: [Session]
}

struct SessionsListView: View {
    let logger = Logger(subsystem: Logger.subsystem, category: "AppDelegate")

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getSessions()) var allSessions: FetchedResults<Session>
    
    @Binding var blockingRefresh : Bool
    
    let sessionPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("DetailView"))
    
    var favouritesOnly: Bool
    var title: String
    
    @State private var selectorIndex = 0
    @State private var searchText = ""
    @State private var isShowingPullToRefresh = false

    @State private var alertItem : AlertItem?

    @State private var sessionIdFromNotification : String?
    @State private var activateSessionFromNotification = false
    
    private let pendingSelectorValue = 3
    
    var config : Config {
        Config.sharedConfig
    }
    
    var sessions : RelevantSessions {
        let pending = self.allSessions
            .filter { (session) -> Bool in
                session.startUtc == nil
            }
            .sorted(by: { $0.wrappedTitle < $1.wrappedTitle })
        
        if (selectorIndex != pendingSelectorValue) {
            let sessions = self.allSessions
                .filter { (session) -> Bool in
                    session.startUtc?.asDate() ?? "" == config.dates[selectorIndex]
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
            
            let grouped = Dictionary(grouping: sessions, by: { $0.wrappedSection })
            
            let sections = Array(grouped.keys).sorted(by: <)
            
            return RelevantSessions(sessions: sessions, sections: sections, grouped: grouped, pending: pending)
        }
        
        return RelevantSessions(sessions: [], sections: [], grouped: [:], pending: pending)
    }
    
    var selectedSession : Session? {
        return self.allSessions
            .filter { (session) -> Bool in
                session.sessionId == $sessionIdFromNotification.wrappedValue ?? nil
            }.first
    }
    
    func refreshSessions() {
        SessionService.refresh() { (status, message, logMessage) in
            logger.debug("Refresh said: \(status.rawValue, privacy: .public), \(message, privacy: .public), \(logMessage, privacy: .public)")

            if (status == .Fail) {
                self.alertItem = AlertContext.build(title: "Refresh failed", message: message, buttonTitle: "OK")
            }
            
            if (status == .Fatal) {
                self.alertItem = AlertContext.buildFatal(title: "Refresh failed", message: message, buttonTitle: "OK", fatalMessage: logMessage)
            }

            self.isShowingPullToRefresh = false
            self.blockingRefresh = false
            
            UserDefaults.standard.set(Date(), forKey: "SessionLastUpdate")
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                DayPicker(selectorIndex: $selectorIndex, showPending: self.sessions.pending.count > 0)
            
                SearchView(searchText: $searchText)
                
                ScrollViewReader { scrollProxy in
                    List {
                        ForEach(self.sessions.sections, id: \.self) { section in
                            Section(header: Text(section)) {
                                ForEach(self.sessions.grouped[section] ?? [], id: \.self) { session in
                                    SessionNavLink(session: session)
                                }
                            }
                        }
                        
                        if (selectorIndex == pendingSelectorValue) {
                            ForEach(self.sessions.pending, id: \.self) { session in
                                SessionNavLink(session: session, pending: true)
                            }
                        }
                    }
                    .onChange(of: self.sessions, perform: { _ in
                        scrollTo(scroll: scrollProxy)
                    })
                    .onAppear() {
                        appear()
                        scrollTo(scroll: scrollProxy)
                    }
                    .resignKeyboardOnDragGesture()
                    .pullToRefresh(isShowing: $isShowingPullToRefresh) {
                        self.refreshSessions()
                    }
                    .alert(item: $alertItem) { alertItem in
                        Alert(
                            title: alertItem.title,
                            message: alertItem.message,
                            dismissButton: Alert.Button.default(
                                alertItem.buttonTitle,
                                action: {
                                    AlertContext.processAlertItem(alertItem: alertItem)
                                }
                            )
                        )
                    }
                    .navigationTitle(title)
                }
                
                if ($sessionIdFromNotification.wrappedValue != nil) {
                    if let session = selectedSession {
                        NavigationLink(
                            destination: SessionDetailView(session: session, pending: false),
                            isActive: $activateSessionFromNotification,
                            label: {
                                EmptyView()
                            }
                        )
                    } else {
                        EmptyView()
                    }
                } else {
                    EmptyView()
                }
            }
            Text("Please choose a session from the list")
        }
        .onReceive(sessionPublisher) { notification in
            if let sessionId = notification.object as? String {
                self.sessionIdFromNotification = sessionId
                self.activateSessionFromNotification = true
            }
        }
    }
    
    func scrollTo(scroll: ScrollViewProxy) {
        if (searchText != "") {
            return
        }
        
        if (selectorIndex == pendingSelectorValue) {
            return
        }

        var scrollId : String?
        
        let scrollToTimestamp = config.dates[selectorIndex] == Date().asDate()
        
        if (scrollToTimestamp && selectorIndex < 2) {
            let currentTimestamp = Date().asTime()
            
            scrollId = self.sessions.sections.filter { section in
                let sectionParts = section.components(separatedBy: " - ")
                
                // We can use string comparison here since we use 24hr clock
                return sectionParts[0] <= currentTimestamp && sectionParts[1] > currentTimestamp
            }.first
        }
        
        if (scrollId == nil) {
            scrollId = self.sessions.sections.first
        }
        
        logger.debug("Want to scroll to \(scrollId ?? "None", privacy: .public)")
        
        if let scrollId = scrollId {
            scroll.scrollTo(scrollId, anchor: .top)
        }

    }

    func appear() {
        let now = Date()
        
        // We have no sessions in list and we are not filtering
        let noSessions = self.sessions.sessions.count == 0 && self.favouritesOnly == false && self.searchText == ""
        
        logger.debug("Checking to see if empty \(noSessions, privacy: .public)")
        
        // It's been at least 30 mins since last update - a 25% chance to update
        let randomChance = Int.random(in: 0..<4) == 0
        var autorefresh = randomChance && now.shouldUpdate(key: "SessionLastUpdate", defaultDate: Date(timeIntervalSince1970: 0), maxSecs: 60 * 30)
        
        logger.debug("Checking to see if should auto refresh \(autorefresh, privacy: .public)")
        
        #if DEBUG
        autorefresh = Bool.random()
        
        logger.debug("Debug - set auto refresh \(autorefresh, privacy: .public)")
        #endif
        
        if (noSessions || autorefresh) {
            self.blockingRefresh = true
            self.refreshSessions()
        }
        
        
        if (now.shouldUpdate(key: "SessionLastDisplayed", defaultDate: Date(timeIntervalSince1970: 0), maxSecs: 60 * 60)) {
            logger.debug("Should set picker")
            
            let nowDate = now.asDate()
            for idx in  0..<3 {
                if (nowDate == self.config.dates[idx]) {
                    logger.debug("Should set picker - matched \(nowDate, privacy: .public)")
                    
                    self.selectorIndex = idx
                }
            }
        }
        
        now.save(key: "SessionLastDisplayed")
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
        
        return SessionsListView(blockingRefresh: .constant(false), favouritesOnly: false, title: "Sessions").environment(\.managedObjectContext, moc)
    }
}
