//

import SwiftUI

class SectionTitle : Identifiable {
    var title : String
    
    init(title: String) {
        self.title = title
    }
}

struct SessionsListView: View {
    var sessions:FetchedResults<Session>
    var title:String
    
    @State private var selectorIndex = 0
    
    var sessionsOnDate : [Session] {
        self.sessions.filter { (session) -> Bool in
            if let start = session.startUtc?.asDate() {
                return start == Config.dates[selectorIndex]
            } else {
                return false    
            }
        }
    }
    
    var sessionsOnDateByHour : [String: [Session]] {
        return Dictionary(grouping: sessionsOnDate, by: { $0.startUtc?.asHour() ?? "00:00" })
    }
    
    var sections : [SectionTitle] {
        return Array(sessionsOnDateByHour.keys).sorted(by: <).map {SectionTitle(title: $0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectorIndex) {
                    Text(Config.dates[0]).tag(0)
                    Text(Config.dates[1]).tag(1)
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                Text("Search bar")
                List {
                    ForEach(self.sections) { section in
                        Section(header: Text(section.title)) {
                            ForEach(self.sessionsOnDateByHour[section.title] ?? []) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    SessionItemView(session: session)
                                }
                            }
                        }
                    }
                }
            }.navigationBarTitle(title)
        }
    }}

