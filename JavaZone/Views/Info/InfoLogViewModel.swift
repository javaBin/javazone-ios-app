import Foundation
import OSLog

@Observable
@MainActor
final class InfoLogViewModel {
    var logs = ""
    var fetchingLogs = true

    func refreshLogView() {
        Task {
            let result = await Task.detached(priority: .userInitiated) {
                guard let logStore = try? OSLogStore(scope: .currentProcessIdentifier) else {
                    return "Unable to get log store"
                }
                let logRange = logStore.position(date: Date().addingTimeInterval(-(3600 * 24)))
                guard let allEntries = try? logStore.getEntries(at: logRange) else {
                    return "Unable to get log entries"
                }
                return allEntries
                    .compactMap { $0 as? OSLogEntryLog }
                    .filter { $0.subsystem == Logger.subsystem }
                    .map { "\($0.date) : \($0.category) : \($0.composedMessage)" }
                    .joined(separator: "\n")
            }.value

            logs = result
            fetchingLogs = false
        }
    }
}
