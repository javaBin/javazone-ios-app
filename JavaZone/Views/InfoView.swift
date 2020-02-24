import SwiftUI

struct InfoView: View {
    @ObservedObject var info = Info.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("JavaZone"), content: {
                    #if DEBUG
                    Text("Conference stuff")
                    
                    ForEach(info.infoItems, id: \.self) { infoItem in
                        NavigationLink(destination: InfoItemView(title: infoItem.title, text: infoItem.body)) {
                            Text(infoItem.title)
                        }
                    }
                    
                    #endif
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
