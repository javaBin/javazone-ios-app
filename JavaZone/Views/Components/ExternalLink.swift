import SwiftUI

struct ExternalLink: View {
    var title : String
    var url : URL
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(self.url)
        }) {
            HStack {
                Image(systemName: "link")
                Text(title)
            }
        }
    }
}

struct ExternalLink_Previews: PreviewProvider {
    static var previews: some View {
        ExternalLink(title: "Test", url: URL(string: "https://java.no")!)
    }
}
