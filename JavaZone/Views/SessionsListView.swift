// Search code based on https://stackoverflow.com/a/58473985/896214

import SwiftUI

class SectionTitle : Identifiable {
    var title : String
    
    init(title: String) {
        self.title = title
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
struct SessionsListView: View {
    var sessions:FetchedResults<Session>
    var title:String
    
    @State private var selectorIndex = 0
    @State private var searchText = ""
    @State private var showCancelButton: Bool = false
    
    var matchingSessions : [Session] {
        if (searchText == "") {
            return sessionsOnDate
        } else {
            return sessionsOnDate.filter { $0.matches(search: searchText) }
        }
    }
    
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
        return Dictionary(grouping: matchingSessions, by: { $0.startUtc?.asHour() ?? "00:00" })
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
                
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")

                        TextField("Search", text: $searchText, onEditingChanged: { isEditing in
                            self.showCancelButton = true
                        }, onCommit: {
                            print("onCommit")
                        }).foregroundColor(.primary).autocapitalization(.none)

                        Button(action: {
                            self.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)

                    if showCancelButton  {
                        Button("Cancel") {
                                UIApplication.shared.endEditing(true)
                                self.searchText = ""
                                self.showCancelButton = false
                        }
                        .foregroundColor(Color(.systemBlue))
                    }
                }
                .padding(.horizontal)
                .navigationBarHidden(showCancelButton)

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
                }.resignKeyboardOnDragGesture()
            }.navigationBarTitle(title)
        }
    }}

