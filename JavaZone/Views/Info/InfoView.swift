import SwiftUI
import os.log

struct InfoView: View {
    @ObservedObject var info = Info.shared
    @State private var isRefreshing = false
    
    var shortItems : [InfoItem] {
        return info.infoItems.filter { (item) -> Bool in
            item.isShort
        }
    }
    
    var longItems : [InfoItem] {
        return info.infoItems.filter { (item) -> Bool in
            !item.isShort
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("JavaZone"), content: {
                    ForEach(shortItems, id: \.self) { infoItem in
                        InfoItemListView(item: infoItem)
                    }
                    ForEach(longItems, id: \.self) { infoItem in
                        NavigationLink(destination: InfoItemView(item: infoItem)) {
                            InfoItemListView(item: infoItem)
                        }
                    }
                    ExternalLink(title: "Code of conduct", url: URL(string: "https://www.java.no/principles.html")!)
                })
                Section(header: Text("JavaZone App"), content: {
                    ExternalLink(title: "GitHub", url: URL(string: "https://github.com/javaBin/javazone-ios-app")!)
                    ExternalLink(title: "Known Issues", url: URL(string: "https://github.com/javaBin/javazone-ios-app/issues")!)
                    NavigationLink(destination: LibrariesAndLicenses()) {
                        Text("Libraries and Licenses")
                    }
                    if #available(iOS 15, *) {
                        Button("Send Logs (last 24 hrs)") {
                            sendLogs()
                        }
                    }
                })
                Section(header: Text("javaBin"), content: {
                    ExternalLink(title: "javaBin", url: URL(string: "https://www.java.no/")!)
                    ExternalLink(title: "Terms and Conditions", url: URL(string: "https://www.java.no/policy.html")!)                    
                })
            }
            .navigationTitle("Info")
            .pullToRefresh(isShowing: $isRefreshing) {
                Info.shared.update(force: true, callback: self.refreshDone)
            }
            .onAppear {
                Info.shared.update(force: false, callback: nil)
            }
        }
    }
    
    func refreshDone() {
        self.isRefreshing = false
    }
    
    @available(iOS 15, *)
    func sendLogs() {
        /*
        let logStore = try OSLogStore(scope: .currentProcessIdentifier)
            
        // Get all the logs from the last hour.
        let oneDayAgo = logStore.position(date: Date().addingTimeInterval(-(3600 * 24)))
        
        // Fetch log objects.
        let allEntries = try logStore.getEntries(at: oneDayAgo)
        
        // Filter the log to be relevant for our specific subsystem
        // and remove other elements (signposts, etc).
        let entries = allEntries
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == Logger.subsystem }
        
        // TODO - sharesheet? Send via email? Post to a gist? Something
        */
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
