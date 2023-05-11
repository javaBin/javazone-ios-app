import SwiftUI
import CoreData
import os.log

struct RelevantSessions : Equatable {
    var sessions: [Session]
    var sections: [String]
    var grouped: [String: [Session]]
    var pending: [Session]
}

struct SessionWithPending : Hashable {
    var session: Session
    var pending: Bool
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
    
    @State private var alertItem : AlertItem?
    
    @State private var path: [SessionWithPending] = []
    
    var config : Config {
        Config.sharedConfig
    }
    
    var sessions : RelevantSessions {
        let pending = self.allSessions
            .filter { (session) -> Bool in
                session.startUtc == nil
            }
            .sorted(by: { $0.wrappedTitle < $1.wrappedTitle })
        
        if (pending.count == 0) {
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
        } else {
            let sessions = self.allSessions
                .filter { (session) -> Bool in
                    if (self.searchText == "") {
                        return true
                    }
                    
                    return session.wrappedTitle.contains(self.searchText) || session.speakerNames.contains(self.searchText)
                }
                .sorted(by: { $0.wrappedTitle < $1.wrappedTitle })
            
            return RelevantSessions(sessions:sessions, sections: [], grouped: [:], pending: pending)
        }
    }
    
    var isPending : Bool {
        return !self.sessions.pending.isEmpty
    }
    
    func refreshSessions() async {
        do {
            defer {
                self.blockingRefresh = false
                
                UserDefaults.standard.set(Date(), forKey: "NSessionLastUpdate")
            }

            let status = try await SessionService.refresh()
            
            logger.debug("Refresh said: \(status.rawValue, privacy: .public)")
        } catch  let error as ServiceError {
            logger.debug("Refresh said: \(error.status.rawValue, privacy: .public), \(error.message, privacy: .public), \(error.detail ?? "Unknown Error", privacy: .public)")
            
            if (error.status == .Fail) {
                self.alertItem = AlertContext.build(title: "Refresh failed", message: error.message, buttonTitle: "OK")
            }
            
            if (error.status == .Fatal) {
                self.alertItem = AlertContext.buildFatal(title: "Refresh failed", message: error.message, buttonTitle: "OK", fatalMessage: error.detail ?? "Unknown Error")
            }
        } catch {
            logger.debug("Refresh unexpected error: \(error, privacy: .public)")
        }

    }
    
    var body: some View {
        NavigationStack(path: $path) {
            if (self.isPending && favouritesOnly) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("The time/date and room schedule is not yet available.")
                    Text("You will be able to add sessions to your personal schedule when the time/date and room schedule has been published.")
                    Spacer()
                }
                .padding()
                .navigationTitle(title)
            } else {
                VStack {
                    if (!self.isPending) {
                        DayPicker(selectorIndex: $selectorIndex)
                    }
                    
                    SearchView(searchText: $searchText)
                    
                    ScrollViewReader { scrollProxy in
                        List {
                            ForEach(self.sessions.sections, id: \.self) { section in
                                Section(header: Text(section)) {
                                    ForEach(self.sessions.grouped[section] ?? [], id: \.self) { session in
                                        SessionNavLink(sessionWithPending: SessionWithPending(session: session, pending: false))
                                    }
                                }
                            }
                            
                            if (self.isPending) {
                                if (favouritesOnly) {
                                    Text("The session program is not yet complete")
                                    Text("Rooms and times are still pending")
                                    Text("You will be able to add sessions to your schedule when the programme is finalized.")
                                    
                                } else {
                                    ForEach(self.sessions.sessions, id: \.self) { session in
                                        SessionNavLink(sessionWithPending: SessionWithPending(session: session, pending: true))
                                    }
                                }
                            }
                        }
                        .navigationDestination(for: SessionWithPending.self, destination: { sessionWithPending in
                            SessionDetailView(session: sessionWithPending.session, pending: sessionWithPending.pending)
                        })
                        .onChange(of: self.sessions, perform: { _ in
                            scrollTo(scroll: scrollProxy)
                        })
                        .onFirstAppear() {
                            appear()
                            scrollTo(scroll: scrollProxy)
                        }
                        .resignKeyboardOnDragGesture()
                        .refreshable(action: {
                            await self.refreshSessions()
                        })
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
                }
            }
        }
        .onReceive(sessionPublisher) { notification in
            if let sessionId = notification.object as? String {
                if let session = self.sessions.pending.first(where: { $0.sessionId == sessionId } ) {
                    self.path = [SessionWithPending(session: session, pending: true)]
                } else if let session = self.sessions.sessions.first(where: { $0.sessionId == sessionId } ) {
                    self.path = [SessionWithPending(session: session, pending: false)]
                }
            }
        }
    }
    
    func scrollTo(scroll: ScrollViewProxy) {
        if (searchText != "") {
            return
        }
        
        if (self.isPending) {
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
            Task {
                self.blockingRefresh = true
                await self.refreshSessions()
            }
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
