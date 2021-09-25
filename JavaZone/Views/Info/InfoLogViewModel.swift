import SwiftUI
import OSLog

class InfoLogViewModel : ObservableObject {
    @Published var logs = ""
    @Published var fetchingLogs = true
    
    @available(iOS 15, *)
    func refreshLogView() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let logStore = try? OSLogStore(scope: .currentProcessIdentifier) else {
                self.logs = "Unable to get log store"
                DispatchQueue.main.async {
                    self.fetchingLogs = false
                }
                return
            }
                
            // Get all the logs from the last 24 hrs.
            let logRange = logStore.position(date: Date().addingTimeInterval(-(3600 * 24)))
            
            // Fetch log objects.
            guard let allEntries = try? logStore.getEntries(at: logRange) else {
                self.logs = "Unable to get log entries"
                DispatchQueue.main.async {
                    self.fetchingLogs = false
                }
                return
            }
            
            let logList = allEntries
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Logger.subsystem }
                .map { "\($0.date) : \($0.category) : \($0.composedMessage)" }
                .joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.logs = logList
                self.fetchingLogs = false
            }
        }
    }
}
