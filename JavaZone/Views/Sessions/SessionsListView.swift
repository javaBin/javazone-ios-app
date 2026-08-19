import SwiftUI
import SwiftData
import os.log

struct RelevantSessions: Equatable {
    var sessions: [Session]
    var sections: [String]
    var grouped: [String: [Session]]
    var pending: [Session]
}

/// Identifies a selected session by its stable `sessionId` rather than by holding the
/// `Session` model object. A refresh batch-deletes every `Session`, so a retained instance
/// would be invalidated and trap on the next property read.
struct SessionWithPending: Hashable {
    var sessionId: String
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
        ForEach(sessions, id: \.persistentModelID) { session in
            SessionNavLink(session: session, pending: pending)
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

    // Explicit: the private @Environment/@State properties would otherwise make the
    // synthesised memberwise initialiser private.
    init(favouritesOnly: Bool, title: String) {
        self.favouritesOnly = favouritesOnly
        self.title = title
    }

    @State private var selectorIndex = 0
    @State private var searchText = ""
    @State private var selectedSession: SessionWithPending?
    @State private var hasAppeared = false
    @State private var scrolledSection: String?

    var sessions: RelevantSessions {
        let pending = allSessions
            .filter { $0.startUtc == nil }
            .sorted { $0.wrappedTitle < $1.wrappedTitle }

        if pending.isEmpty {
            let filtered = allSessions
                .filter { ($0.startUtc?.asDate() ?? "") == appConfig.dates[selectorIndex] }
                .filter { $0.favourite || !favouritesOnly }
                .filter { matchesSearch($0) }

            let grouped = Dictionary(grouping: filtered, by: \.wrappedSection)
            let sections = grouped.keys.sorted()
            return RelevantSessions(sessions: filtered, sections: sections, grouped: grouped, pending: pending)
        } else {
            let filtered = allSessions
                .filter { matchesSearch($0) }
                .sorted { $0.wrappedTitle < $1.wrappedTitle }
            return RelevantSessions(sessions: filtered, sections: [], grouped: [:], pending: pending)
        }
    }

    private func matchesSearch(_ session: Session) -> Bool {
        searchText.isEmpty
            || session.wrappedTitle.localizedCaseInsensitiveContains(searchText)
            || session.speakerNames.localizedCaseInsensitiveContains(searchText)
    }

    private var alertItemBinding: Binding<AlertItem?> {
        Binding(
            get: { sessionsViewModel.alertItem },
            set: { sessionsViewModel.alertItem = $0 }
        )
    }

    var body: some View {
        // Computed once per render pass and threaded through to the helpers below —
        // filtering, sorting and grouping the whole programme is not free.
        let relevant = sessions
        let isPending = !relevant.pending.isEmpty
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

                        List(selection: $selectedSession) {
                            ForEach(relevant.sections, id: \.self) { section in
                                Section(header: Text(section)) {
                                    SessionListEntries(sessions: relevant.grouped[section] ?? [], pending: false)
                                }
                            }
                            if isPending {
                                if favouritesOnly {
                                    Text("The session program is not yet complete")
                                    Text("Rooms and times are still pending")
                                    // swiftlint:disable:next line_length
                                    Text("You will be able to add sessions to your schedule when the programme is finalized.")
                                } else {
                                    SessionListEntries(sessions: relevant.sessions, pending: true)
                                }
                            }
                        }
                        .scrollPosition(id: $scrolledSection, anchor: .top)
                        .onChange(of: selectorIndex) {
                            scrollTo(sessions)
                        }
                        .onChange(of: sessionsViewModel.isRefreshing) { _, isRefreshing in
                            if !isRefreshing { scrollTo(sessions) }
                        }
                        .task {
                            guard !hasAppeared else { return }
                            hasAppeared = true
                            appear(relevant)
                            scrollTo(sessions)
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
                                dismissButton: .default(alertItem.buttonTitle)
                            )
                        }
                        .navigationTitle(title)
                    }
                }
            }
        } detail: {
            if let selectedSession,
               let session = allSessions.first(where: { $0.sessionId == selectedSession.sessionId }) {
                SessionDetailView(session: session, pending: selectedSession.pending)
            } else {
                Text("Please choose a session")
            }
        }
        .onChange(of: notificationRouter.sessionId) { _, newSessionId in
            handleNotificationRoute(newSessionId)
        }
    }

    /// Only the Sessions tab routes notification taps — otherwise both list instances
    /// would react to the same tap. The router is cleared once consumed so that tapping a
    /// reminder for the same session twice still navigates.
    private func handleNotificationRoute(_ newSessionId: String?) {
        guard !favouritesOnly, let sessionId = newSessionId else { return }
        defer { notificationRouter.sessionId = nil }

        let current = sessions
        if current.pending.contains(where: { $0.sessionId == sessionId }) {
            selectedSession = SessionWithPending(sessionId: sessionId, pending: true)
        } else if current.sessions.contains(where: { $0.sessionId == sessionId }) {
            selectedSession = SessionWithPending(sessionId: sessionId, pending: false)
        }
    }

    private func scrollTo(_ current: RelevantSessions) {
        guard searchText.isEmpty, current.pending.isEmpty else { return }

        var target: String?
        let scrollToTimestamp = appConfig.dates[selectorIndex] == Date().asDate()

        if scrollToTimestamp && selectorIndex < 2 {
            let currentTimestamp = Date().asTime()
            target = current.sections.last(where: { $0 <= currentTimestamp })
        }

        if target == nil { target = current.sections.first }

        logger.debug("Want to scroll to \(target ?? "None", privacy: .public)")
        scrolledSection = target
    }

#if DEBUG
    /// One forced refresh per process. `appear()` also fires on tab switches and on the
    /// favourites instance of this view, and a second refresh mid-run would batch-delete
    /// the sessions the UI test is currently navigating.
    @MainActor private static var hasForcedRefresh = false
#endif

    private func appear(_ current: RelevantSessions) {
        let now = Date()
        let noSessions = current.sessions.isEmpty && !favouritesOnly && searchText.isEmpty
        let randomChance = Int.random(in: 0..<4) == 0
        var autorefresh = randomChance && now.shouldUpdate(
            key: "SessionLastUpdate",
            defaultDate: Date(timeIntervalSince1970: 0),
            maxSecs: 60 * 30
        )

#if DEBUG
        autorefresh = Bool.random()

        // Screenshot runs must not ride on the coin flip above: a simulator carrying last
        // year's store has sessions, so `noSessions` is false, and a tails flip leaves both
        // the list and `conferenceUrl` on stale data.
        if ProcessInfo.processInfo.arguments.contains("--force-refresh"), !Self.hasForcedRefresh {
            Self.hasForcedRefresh = true
            autorefresh = true
        }

        logger.debug("Debug — set auto refresh \(autorefresh, privacy: .public)")
#endif

        if noSessions || autorefresh {
            Task {
                await sessionsViewModel.refresh(context: modelContext, appConfig: appConfig)
            }
        }

        let displayKey = "SessionLastDisplayed"
        if now.shouldUpdate(key: displayKey, defaultDate: Date(timeIntervalSince1970: 0), maxSecs: 60 * 60) {
            let nowDate = now.asDate()
            for idx in 0..<min(3, appConfig.dates.count) where nowDate == appConfig.dates[idx] {
                selectorIndex = idx
            }
        }

        now.save(key: displayKey)
    }
}

#Preview {
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Session.self, SessionBody.self, Speaker.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    SessionsListView(favouritesOnly: false, title: "Sessions")
        .modelContainer(container)
        .environment(SessionsViewModel())
        .environment(AppConfig())
        .environment(NotificationRouter())
}
