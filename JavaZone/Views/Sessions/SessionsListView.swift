import SwiftUI
import CoreData
import os.log

struct RelevantSessions: Equatable {
    var sessions: [Session]
    var sections: [String]
    var grouped: [String: [Session]]
    var pending: [Session]
}

struct SessionWithPending: Hashable {
    var session: Session
    var pending: Bool
}

struct PendingView: View {
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The time/date and room schedule is not yet available.")
            Text("""
You will be able to add sessions to your personal schedule when \
the time/date and room schedule has been published.
"""
            )
            Spacer()
        }
        .padding()
        .navigationTitle(title)
    }
}

struct SessionListEntries: View {
    var sessions: [Session]
    var pending: Bool

    var body: some View {
        ForEach(sessions, id: \.self) { session in
            SessionNavLink(sessionWithPending: SessionWithPending(session: session, pending: pending))
        }
    }
}

struct SessionsListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getSessions()) var allSessions: FetchedResults<Session>

    @Binding var blockingRefresh: Bool

    let sessionPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("DetailView"))

    var favouritesOnly: Bool
    var title: String

    @State private var selectorIndex = 0
    @State private var searchText = ""

    @State private var alertItem: AlertItem?

    @State private var selectedSession: SessionWithPending?

    var config: Config {
        Config.sharedConfig
    }

    var sessions: RelevantSessions {
        let pending = self.allSessions
            .filter { (session) -> Bool in
                session.startUtc == nil
            }
            .sorted(by: { $0.title.val() < $1.title.val() })

        if pending.count == 0 {
            let sessions = self.allSessions
                .filter { (session) -> Bool in
                    session.startUtc?.asDate() ?? "" == config.dates[selectorIndex]
                }
                .filter { (session) -> Bool in
                    session.favourite == true || self.favouritesOnly == false
                }
                .filter { (session) -> Bool in
                    if self.searchText == "" {
                        return true
                    }

                    return searchMatch(search: self.searchText, session: session)
                }

            let grouped = Dictionary(grouping: sessions, by: { $0.section.val("??") })

            let sections = Array(grouped.keys).sorted(by: <)

            return RelevantSessions(sessions: sessions, sections: sections, grouped: grouped, pending: pending)
        } else {
            let sessions = self.allSessions
                .filter { (session) -> Bool in
                    if self.searchText == "" {
                        return true
                    }

                    return searchMatch(search: self.searchText, session: session)
                }
                .sorted(by: { $0.title.val() < $1.title.val() })

            return RelevantSessions(sessions: sessions, sections: [], grouped: [:], pending: pending)
        }
    }

    var isPending: Bool {
        return !self.sessions.pending.isEmpty
    }

    func searchMatch(search: String, session: Session) -> Bool {
        return session.title.val().contains(search) || session.speakerNames.contains(search)
    }

    func refreshSessions() async {
        do {
            defer {
                self.blockingRefresh = false

                UserDefaults.standard.set(Date(), forKey: "NSessionLastUpdate")
            }

            let status = try await SessionService.refresh()

            Logger.interaction.debug("SessionsListView: refreshSessions: \(status.rawValue, privacy: .public)")
        } catch  let error as ServiceError {
            Logger.interaction.debug("""
SessionsListView: refreshSessions: \(error.status.rawValue, privacy: .public), \
\(error.message, privacy: .public), \
\(error.detail ?? "Unknown Error", privacy: .public)
"""
            )

            if error.status == .fail {
                self.alertItem = AlertContext.build(title: "Refresh failed", message: error.message, buttonTitle: "OK")
            }

            if error.status == .fatal {
                self.alertItem = AlertContext.buildFatal(title: "Refresh failed",
                                                         message: error.message,
                                                         buttonTitle: "OK",
                                                         fatalMessage: error.detail ?? "Unknown Error")
            }
        } catch {
            Logger.interaction.debug("SessionsListView: refreshSessions: unexpected error: \(error, privacy: .public)")
        }

    }

    var body: some View {
        NavigationSplitView {
            NavigationStack {
                if self.isPending && favouritesOnly {
                    PendingView(title: title)
                } else {
                    VStack {
                        if !self.isPending {
                            DayPicker(selectorIndex: $selectorIndex)
                        }

                        SearchView(searchText: $searchText)

                        ScrollViewReader { scrollProxy in
                            List(selection: $selectedSession) {
                                ForEach(self.sessions.sections, id: \.self) { section in
                                    Section(header: Text(section)) {
                                        SessionListEntries(sessions: self.sessions.grouped[section] ?? [],
                                                           pending: false)
                                    }
                                }

                                if self.isPending {
                                    if favouritesOnly {
                                        Text("The session program is not yet complete.")
                                        Text("Rooms and times are still pending.")
                                        Text("You will be able to update your schedule when the programme is ready.")

                                    } else {
                                        SessionListEntries(sessions: self.sessions.sessions, pending: true)
                                    }
                                }
                            }
                            .onChange(of: self.sessions) {
                                scrollTo(scroll: scrollProxy)
                            }
                            .onFirstAppear {
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
        } detail: {
            if let selectedSession = selectedSession {
                SessionDetailView(session: selectedSession.session, pending: selectedSession.pending)
            } else {
                Text("Please choose a session")
            }
        }
        .onReceive(sessionPublisher) { notification in
            if let sessionId = notification.object as? String {
                if let session = self.sessions.pending.first(where: { $0.sessionId == sessionId }) {
                    self.selectedSession = SessionWithPending(session: session, pending: true)
                } else if let session = self.sessions.sessions.first(where: { $0.sessionId == sessionId }) {
                    self.selectedSession = SessionWithPending(session: session, pending: false)
                }
            }
        }
    }

    func scrollTo(scroll: ScrollViewProxy) {
        if searchText != "" {
            return
        }

        if self.isPending {
            return
        }

        var scrollId: String?

        let scrollToTimestamp = config.dates[selectorIndex] == Date().asDate()

        if scrollToTimestamp && selectorIndex < 2 {
            let currentTimestamp = Date().asTime()

            scrollId = self.sessions.sections.filter { section in
                let sectionParts = section.components(separatedBy: " - ")

                // We can use string comparison here since we use 24hr clock
                return sectionParts[0] <= currentTimestamp && sectionParts[1] > currentTimestamp
            }.first
        }

        if scrollId == nil {
            scrollId = self.sessions.sections.first
        }

        Logger.interaction.debug("""
SessionsListView: scrollTo: Want to scroll to \(scrollId ?? "None", privacy: .public)
"""
        )

        if let scrollId = scrollId {
            scroll.scrollTo(scrollId, anchor: .top)
        }

    }

    func appear() {
        let now = Date()

        // We have no sessions in list and we are not filtering
        let noSessions = self.sessions.sessions.count == 0 && self.favouritesOnly == false && self.searchText == ""

        Logger.viewCycle.debug("SessionsListView: appear: Checking to see if empty \(noSessions, privacy: .public)")

        // It's been at least 30 mins since last update - a 25% chance to update
        let randomChance = Int.random(in: 0..<4) == 0
        var autorefresh = randomChance && now.shouldUpdate(key: "SessionLastUpdate",
                                                           defaultDate: Date(timeIntervalSince1970: 0),
                                                           maxSecs: 60 * 30)

        Logger.viewCycle.debug("""
SessionsListView: appear: Checking to see if should auto refresh \(autorefresh, privacy: .public)
"""
        )

#if DEBUG
        autorefresh = Bool.random()

        Logger.viewCycle.debug("SessionsListView: appear: Debug - set auto refresh \(autorefresh, privacy: .public)")
#endif

        if noSessions || autorefresh {
            Task {
                self.blockingRefresh = true
                await self.refreshSessions()
            }
        }

        if now.shouldUpdate(key: "SessionLastDisplayed",
                            defaultDate: Date(timeIntervalSince1970: 0),
                            maxSecs: 60 * 60) {
            Logger.viewCycle.debug("SessionsListViewappear: Should set picker")

            let nowDate = now.asDate()
            for idx in  0..<3 where nowDate == self.config.dates[idx] {
                Logger.viewCycle.debug("""
SessionsListViewappear: Should set picker - matched \(nowDate, privacy: .public)
"""
                )

                self.selectorIndex = idx
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
            session.abstract = """
This is a test abstract about the talk. I need a longer string to test the preview better
"""
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

        return SessionsListView(blockingRefresh: .constant(false),
                                favouritesOnly: false,
                                title: "Sessions").environment(\.managedObjectContext, moc)
    }
}
