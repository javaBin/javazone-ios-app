import SwiftUI

struct InfoView: View {
    @ObservedObject var info = Info.shared
    
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
                })
                Section(header: Text("javaBin"), content: {
                    ExternalLink(title: "javaBin", url: URL(string: "https://www.java.no/")!)
                    ExternalLink(title: "Terms and Conditions", url: URL(string: "https://www.java.no/policy.html")!)                    
                })
            }
            .navigationBarTitle("Info")
            .onAppear {
                Info.shared.update()
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
