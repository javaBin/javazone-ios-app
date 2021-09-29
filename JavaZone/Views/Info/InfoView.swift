import SwiftUI

struct InfoView: View {
    @StateObject var viewModel = InfoViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("JavaZone"), content: {
                    ForEach(viewModel.shortItems, id: \.self) { infoItem in
                        InfoItemListView(item: infoItem)
                    }
                    ForEach(viewModel.longItems, id: \.self) { infoItem in
                        NavigationLink(destination: InfoItemView(item: infoItem)) {
                            InfoItemListView(item: infoItem)
                        }
                    }
                    ExternalLink(title: "Code of conduct", url: URL(string: "https://www.java.no/principles.html")!)
                })
                Section(header: Text("JavaZone App"), content: {
                    ExternalLink(title: "GitHub", url: URL(string: "https://github.com/javaBin/javazone-ios-app")!)
                    ExternalLink(title: "Known Issues", url: URL(string: "https://github.com/javaBin/javazone-ios-app/issues")!)
                    NavigationLink(destination: LicenceListView()) {
                        Text("Licences")
                    }
                    if #available(iOS 15, *) {
                        NavigationLink(destination: InfoLogView()) {
                            Text("App Logs")
                        }
                    }
                })
                Section(header: Text("javaBin"), content: {
                    ExternalLink(title: "javaBin", url: URL(string: "https://www.java.no/")!)
                    ExternalLink(title: "Terms and Conditions", url: URL(string: "https://www.java.no/policy.html")!)                    
                })
            }
            .navigationTitle("Info")
            .pullToRefresh(isShowing: $viewModel.fetchingItems) {
                viewModel.refreshItems(force: true)
            }
            .onAppear {
                viewModel.refreshItems(force: false)
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
