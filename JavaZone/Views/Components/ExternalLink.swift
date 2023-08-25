import SwiftUI
import Flurry_iOS_SDK

struct ExternalLink: View {
    var title : String
    var url : URL
    
    var image : String = "link"
    
    var body: some View {
        Button(action: {
            Flurry.log(eventName: "ExternalLinkOpened", parameters: ["Link": self.url.absoluteString])
            
            UIApplication.shared.open(self.url)
        }) {
            HStack {
                if (image != "") {
                    Image(systemName: image)
                }
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
