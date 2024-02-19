import SwiftUI

struct ExternalLink: View {
    var title: String
    var url: URL

    var image: String = "link"

    var body: some View {
        Button(action: {
            UIApplication.shared.open(self.url)
        }, label: {
            HStack {
                if image != "" {
                    Image(systemName: image)
                }
                Text(title)
            }
        })
    }
}

struct ExternalLink_Previews: PreviewProvider {
    static var previews: some View {
        ExternalLink(title: "Test", url: URL(string: "https://java.no")!)
    }
}
