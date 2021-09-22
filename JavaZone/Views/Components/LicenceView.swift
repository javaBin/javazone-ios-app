import SwiftUI

struct LicenceView: View {
    
    var title : String
    var link : URL?
    var text : String
    
    var body: some View {
        ScrollView {
            VStack {
                if (link != nil) {
                    ExternalLink(title: "\(title)'s website", url: link!)
                }
                Text(text).padding(.horizontal)
            }.navigationTitle(title)
        }
    }
}

struct LicenceView_Previews: PreviewProvider {
    static var previews: some View {
        LicenceView(title: "Test", link: URL(string: "https://java.no")!, text: "Test")
    }
}
