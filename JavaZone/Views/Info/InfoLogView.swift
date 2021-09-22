import SwiftUI
import OSLog

struct InfoLogView: View {
    @State var logs = ""
    @State var fetchingLogs = true
    
    var body: some View {
        VStack {
            if #available(iOS 15, *) {
                Text("If you are having problems then we might ask you for your logs.")
                    .padding(.horizontal)
                    .navigationTitle("Logs for the last 24 hrs")
                    .onAppear(perform: refreshLogView)
                if (fetchingLogs) {
                    ProgressView("Fetching last 24 hours of logs")
                } else {
                    Text("Simply copy/share the following:")
                        .padding(.horizontal).padding(.top, 20)
                    ScrollView(.vertical) {
                        Text("\(logs)").textSelection(.enabled).padding(.horizontal).padding(.top, 20).padding(.horizontal)
                    }
                }
                Spacer()
            } else {
                Text("Logs are only available on iOS 15 or later.")
            }
        }
    }
    
    
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
            
            self.logs = allEntries
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Logger.subsystem }
                .map { "\($0.date) : \($0.category) : \($0.composedMessage)" }
                .joined(separator: "\n")
            
            DispatchQueue.main.async {
                self.fetchingLogs = false
            }
        }
    }
}

struct InfoLogView_Previews: PreviewProvider {
    static var previews: some View {
        InfoLogView()
    }
}
