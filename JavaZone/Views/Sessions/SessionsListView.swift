import SwiftUI
import SwiftData
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
            Text("You will be able to add sessions to your personal schedule when the time/date and room schedule has been published.")
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
        ForEach(sessions, id: \.persistentModelID) { session in
            SessionNavLink(sessionWithPending: SessionWithPending(session: session, pending: pending))
        }
    }
}

struct SessionsListView: View {
    private let logger = Logger(subsystem: Logger.subsystem, category: "SessionsListView")

    @Query(sort: [
        SortDescriptor(\Session.startUtc),
        SortDescriptor(\Session.format, order: .reverse),
        SortDescriptor(\Session.room)
    ])
    var allSessions: [Session]

    @Environment(\.modelContext) private var modelContext
    @Environment(AppConfig.self) private var appConfig
    @Environment(SessionsViewModel.self) private var sessionsViewModel
    @Environment(NotificationRouter.self) private var notificationRouter

    var favouritesOnly: Bool
    var title: String

    init(favouritesOnly: Bool, title: String) {
        self.favouritesOnly = favouritesOnly
        self.title = title
        self._allSessions = Query(sort: [
            SortDescriptor(\Session.startUtc),
            SortDescriptor(\Session.format, order: .reverse),
            SortDescriptor(\Session.room)
        ])
    }

    @State private var selectorIndex = 0
    @State private var searchText = ""
    @State private var selectedSession: SessionWithPending?

    var sessions: RelevantSessions {
        let pending = allSessions
            .filter { $0.startUtc == nil }
            .sorted { $0.wrappedTitle < $1.wrappedTitle }

        if pending.isEmpty {
            let filtered = allSessions
                .filter { $0.startUtc?.asDate() ?? "" == appConfig.dates[selectorIndex] }
                .filter { $0.favourite || !favouritesOnly }
                .filter { searchText.isEmpty || $0.wrappedTitle.localizedCaseInsensitiveContains(searchText) || $0.speakerNames.localizedCaseInsensitiveContains(searchText) }

            let grouped = Dictionary(grouping: filtered, by: \.wrappedSection)
            let sections = grouped.keys.sorted()
            return RelevantSessions(sessions: filtered, sections: sections, grouped: grouped, pending: pending)
        } else {
            let filtered = allSessions
                .filter { searchText.isEmpty || $0.wrappedTitle.localizedCaseInsensitiveContains(searchText) || $0.speakerNames.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.wrappedTitle < $1.wrappedTitle }
            return RelevantSessions(sessions: filtered, sections: [], grouped: [:], pending: pending)
        }
    }

    var isPending: Bool { !sessions.pending.isEmpty }

    private var alertItemBinding: Binding<AlertItem?> {
        Binding(
            get: { sessionsViewModel.alertItem },
            set: { sessionsViewModel.alertItem = $0 }
        )
    }

    var body: some View {
        NavigationSplitView {
            NavigationStack {
                if isPending && favouritesOnly {
                    PendingView(title: title)
                } else {
                    VStack {
                        if !isPending {
                            DayPicker(selectorIndex: $selectorIndex)
                        }
                        SearchView(searchText: $searchText)

                        ScrollViewReader { scrollProxy in
                            List(selection: $selectedSession) {
                                ForEach(sessions.sections, id: \.self) { section in
                                    Section(header: Text(section)) {
                                        SessionListEntries(sessions: sessions.grouped[section] ?? [], pending: false)
                                    }
                                }
                                if isPending {
                                    if favouritesOnly {
                                        Text("The session program is not yet complete")
                                        Text("Rooms and times are still pending")
                                        Text("You will be able to add sessions to your schedule when the programme is finalized.")
                                    } else {
                                        SessionListEntries(sessions: sessions.sessions, pending: true)
                                    }
                                }
                            }
                            .onChange(of: sessions) {
                                scrollTo(scroll: scrollProxy)
                            }
                            .task {
                                appear()
                                scrollTo(scroll: scrollProxy)
                            }
                            .scrollContentBackground(.hidden)
                            .resignKeyboardOnDragGesture()
                            .refreshable {
                                await sessionsViewModel.refresh(context: modelContext, appConfig: appConfig)
                            }
                            .alert(item: alertItemBinding) { alertItem in
                                Alert(
                                    title: alertItem.title,
                                    message: alertItem.message,
                                    dismissButton: .default(alertItem.buttonTitle) {
                                        AlertContext.processAlertItem(alertItem: alertItem)
                                    }
                                )
                            }
                            .navigationTitle(title)
                        }
                    }
                }
            }
        } detail: {
            if let selectedSession {
                SessionDetailView(session: selectedSession.session, pending: selectedSession.pending)
            } else {
                Text("Please choose a session")
            }
        }
        .onChange(of: notificationRouter.sessionId) { _, newSessionId in
            guard let sessionId = newSessionId else { return }
            if let session = sessions.pending.first(where: { $0.sessionId == sessionId }) {
                selectedSession = SessionWithPending(session: session, pending: true)
            } else if let session = sessions.sessions.first(where: { $0.sessionId == sessionId }) {
                selectedSession = SessionWithPending(session: session, pending: false)
            }
        }
    }

    private func scrollTo(scroll: ScrollViewProxy) {
        guard searchText.isEmpty, !isPending else { return }

        var scrollId: String?
        let scrollToTimestamp = appConfig.dates[selectorIndex] == Date().asDate()

        if scrollToTimestamp && selectorIndex < 2 {
            let currentTimestamp = Date().asTime()
            scrollId = sessions.sections.first { section in
                let parts = section.components(separatedBy: " - ")
                guard parts.count == 2 else { return false }
                return parts[0] <= currentTimestamp && parts[1] > currentTimestamp
            }
        }

        if scrollId == nil { scrollId = sessions.sections.first }

        logger.debug("Want to scroll to \(scrollId ?? "None", privacy: .public)")
        if let scrollId { scroll.scrollTo(scrollId, anchor: .top) }
    }

    private func appear() {
        let now = Date()
        let noSessions = sessions.sessions.isEmpty && !favouritesOnly && searchText.isEmpty
        let randomChance = Int.random(in: 0..<4) == 0
        var autorefresh = randomChance && now.shouldUpdate(
            key: "SessionLastUpdate",
            defaultDate: Date(timeIntervalSince1970: 0),
            maxSecs: 60 * 30
        )

#if DEBUG
        autorefresh = Bool.random()
        logger.debug("Debug — set auto refresh \(autorefresh, privacy: .public)")
#endif

        if noSessions || autorefresh {
            Task {
                await sessionsViewModel.refresh(context: modelContext, appConfig: appConfig)
            }
        }

        if now.shouldUpdate(key: "SessionLastDisplayed", defaultDate: Date(timeIntervalSince1970: 0), maxSecs: 60 * 60) {
            let nowDate = now.asDate()
            for idx in 0..<min(3, appConfig.dates.count) {
                if nowDate == appConfig.dates[idx] {
                    selectorIndex = idx
                }
            }
        }

        now.save(key: "SessionLastDisplayed")
    }
}

#Preview {
    SessionsListView(favouritesOnly: false, title: "Sessions")
        .modelContainer(try! ModelContainer(for: Session.self, Speaker.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
        .environment(SessionsViewModel())
        .environment(AppConfig())
        .environment(NotificationRouter())
}
