import CoreData
import OSLog

class SessionViewModel: ObservableObject {
    let container: NSPersistentContainer

    @Published var sessions: [Session] = [] {
        willSet {
            update(updatedSessions: newValue)
        }
    }

    @Published var relevantSessions: [Session] = []
    @Published var pendingSessions: [Session] = []
    @Published var sections: [String] = []
    @Published var grouped: [String: [Session]] = [:]

    @Published var pendingOnly: Bool = false

    @Published var selectedIndex: Int = 0
    @Published var blockingRefresh: Bool = false

    init() {
        container = CoreDataManager.shared.persistentContainer

        fetchSessions()
    }

    func refresh() {
        Logger.datastore.info("SessionViewModel:refresh")
        fetchSessions()
    }

    private func fetchSessions() {
        Logger.datastore.info("SessionViewModel:fetchSessions")
        let request = Session.getSessions()

        do {
            sessions = try container.viewContext.fetch(request)

            Logger.datastore.info("SessionViewModel:fetchSessions:\(self.sessions.count)")
        } catch let error {
            Logger.datastore.error("SessionViewModel: fetchSessions.Error fetching sessions \(error.localizedDescription)")
        }
    }

    private func update(updatedSessions: [Session]) {
        Logger.datastore.info("SessionViewModel:update")

        self.pendingSessions = updatedSessions
            .filter { (session) -> Bool in
                session.startUtc == nil
            }
            .sorted(by: { $0.title.val() < $1.title.val() })

        Logger.datastore.info("SessionViewModel:update:pending:\(self.pendingSessions.count)")

        if pendingSessions.count == 0 {
            self.relevantSessions = updatedSessions
                .filterForDate(selectorIndex: selectedIndex, config: Config.sharedConfig)
            // TODO - values
                .filterForFavourites(favourite: false, favouritesOnly: false)
                .filterForSearch(searchText: "")

            self.grouped = Dictionary(grouping: relevantSessions, by: { $0.section.val("??") })
            self.sections = Array(grouped.keys).sorted(by: <)

            self.pendingOnly = false
        } else {
            self.relevantSessions = updatedSessions
                .filterForSearch(searchText: "")
                .sorted(by: { $0.title.val() < $1.title.val() })

            self.grouped = [:]
            self.sections = []

            self.pendingOnly = true
        }

        Logger.datastore.info("SessionViewModel:update:sessions:\(updatedSessions.count)")
        Logger.datastore.info("SessionViewModel:update:relevant:\(self.relevantSessions.count)")
        Logger.datastore.info("SessionViewModel:update:sections:\(self.sections)")
    }

    func refreshRemoteSessions() async {
        Task {
            do {
                let remoteSessions = try await SessionService.refresh()
                
                Logger.interaction.debug("SessionViewModel: refreshRemoteSessions: Processing response")

                var newSessions: [Session] = []

                let favourites = getFavourites()
                
                remoteSessions.forEach { (remoteSession) in
                    newSessions.append(
                        InfoItem(
                            title: remoteInfoItem.title,
                            body: remoteInfoItem.body,
                            infoType: remoteInfoItem.infoType,
                            urlTitle: remoteInfoItem.url?.title,
                            url: remoteInfoItem.url?.url))
                }

                Logger.interaction.debug("InfoViewModel: refreshItems: Saw \(newItems.count) info items")

                self.lastUpdated = Date()

                Logger.interaction.debug("""
InfoViewModel: refreshItems: Setting cache flag to \(self.lastUpdated, privacy: .public)
"""
                )

                let completedItems = newItems

                await MainActor.run {
                    self.items = completedItems
                    self.fetchingItems = false
                }
            } catch {
                Logger.interaction.debug("""
    SessionViewModel: refreshRemoteSessions: Unable to refresh \(error, privacy: .public)
    """
                )
            }
        }
        
/*        do {
            defer {
                self.blockingRefresh = false

                UserDefaults.standard.set(Date(), forKey: "NSessionLastUpdate")
            }

            
            
            
            let status = try await SessionServiceOld.refresh()

            Logger.interaction.debug("SessionsListView: refreshSessions: \(status.rawValue, privacy: .public)")
        } catch  let error as ServiceError {
            Logger.interaction.debug("""
SessionsListView: refreshSessions: \(error.status.rawValue, privacy: .public), \
\(error.message, privacy: .public), \
\(error.detail ?? "Unknown Error", privacy: .public)
"""
            )

            /* TODO - alert on error
             
             if error.status == .fail {
                 self.alertItem = AlertContext.build(title: "Refresh failed", message: error.message, buttonTitle: "OK")
             }

             if error.status == .fatal {
                 self.alertItem = AlertContext.buildFatal(title: "Refresh failed",
                                                          message: error.message,
                                                          buttonTitle: "OK",
                                                          fatalMessage: error.detail ?? "Unknown Error")
             }
             */
        } catch {
            Logger.interaction.debug("SessionsListView: refreshSessions: unexpected error: \(error, privacy: .public)")
        }
 */

    }
    
    private func getFavourites() -> [String] {
        Logger.datastore.debug("SessionViewModel: refresh: Getting favourites")

        return self.sessions.filter { (session) -> Bool in
            session.favourite == true
        }.filter { session in
            session.sessionId != nil
        }.map { session in
            session.sessionId!
        }
    }
}

extension Array where Element == Session {
    func filterForDate(selectorIndex: Int, config: Config) -> [Session] {
        return self
            .filter { (session) -> Bool in
                session.startUtc?.asDate() ?? "" == config.dates[selectorIndex]
            }
    }

    func filterForFavourites(favourite: Bool, favouritesOnly: Bool) -> [Session] {
        return self
            .filter { (session) -> Bool in
                session.favourite == favourite || favouritesOnly == false
            }
    }

    func filterForSearch(searchText: String) -> [Session] {
        return self
            .filter { (session) -> Bool in
                if searchText == "" {
                    return true
                }

                return session.title.val().contains(searchText) || session.speakerNames.contains(searchText)
            }
    }
}
