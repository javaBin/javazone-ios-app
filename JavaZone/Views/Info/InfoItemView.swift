import SwiftUI

struct InfoItemView: View {
    var item: InfoItem

    var body: some View {
        VStack {
            if item.isUrgent {
                HStack {
                    Image(systemName: "exclamationmark.octagon.fill")
                    Text("Urgent")
                    }.foregroundColor(Color.yellow).padding()
            }
            Text(item.wrappedBody)
                .padding()
                .navigationTitle(Text(item.title))
                .navigationBarTitleDisplayMode(.inline)
            if item.wrappedLink != nil {
                ExternalLink(title: item.wrappedLinkTitle, url: item.wrappedLink!)
            }
            Spacer()
        }
    }
}

struct InfoItemView_Previews: PreviewProvider {
    static var previews: some View {
        InfoItemView(item: InfoItem(title: "Test", body: "Test", infoType: "urgent"))
    }
}
