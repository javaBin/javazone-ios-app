import SwiftUI

struct InfoView: View {
    @State private var viewModel = InfoViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("JavaZone")) {
                    ForEach(viewModel.shortItems, id: \.self) { item in
                        InfoItemListView(item: item)
                    }
                    ForEach(viewModel.longItems, id: \.self) { item in
                        NavigationLink(destination: InfoItemView(item: item)) {
                            InfoItemListView(item: item)
                        }
                    }
                    ExternalLink(title: "Code of conduct", url: URL(string: "https://www.java.no/principles.html")!)
                }
                Section(header: Text("JavaZone App")) {
                    ExternalLink(title: "GitHub", url: URL(string: "https://github.com/javaBin/javazone-ios-app")!)
                    ExternalLink(title: "Known Issues", url: URL(string: "https://github.com/javaBin/javazone-ios-app/issues")!)
                    NavigationLink(destination: LicenceListView()) {
                        Text("Licences")
                    }
                    NavigationLink(destination: InfoLogView()) {
                        Text("App Logs")
                    }
                }
                Section(header: Text("javaBin")) {
                    ExternalLink(title: "javaBin", url: URL(string: "https://www.java.no/")!)
                    ExternalLink(title: "Terms and Conditions", url: URL(string: "https://www.java.no/policy.html")!)
                }
            }
            .navigationTitle("Info")
            .refreshable {
                viewModel.refreshItems(force: true)
            }
            .task {
                viewModel.refreshItems()
            }
        }
    }
}

#Preview {
    InfoView()
}
