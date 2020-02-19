import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("JavaZone"), content: {
                    Text("Conference stuff")
                    Text("Code of conduct")
                })
                Section(header: Text("JavaZone App"), content: {
                    ExternalLink(title: "GitHub", url: URL(string: "https://github.com/javaBin/javazone-ios-app")!)
                    ExternalLink(title: "Known Issues", url: URL(string: "https://github.com/javaBin/javazone-ios-app/issues")!)
                    Text("Free and open source licenses")
                })
                Section(header: Text("javaBin"), content: {
                    ExternalLink(title: "javaBin", url: URL(string: "https://www.java.no/")!)
                    ExternalLink(title: "Terms and Conditions", url: URL(string: "https://www.java.no/policy.html")!)                    
                })
            }
            .navigationBarTitle("Info")
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
