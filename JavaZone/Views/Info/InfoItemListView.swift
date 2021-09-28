import SwiftUI

struct InfoItemListView: View {
    var item: InfoItem
    
    var body: some View {
        HStack {
            Image(systemName: item.isUrgent ? "exclamationmark.octagon.fill" : "info.circle")
            Text(item.title)
        }
        .foregroundColor(item.isUrgent ? Color.yellow : Color.primary)
    }
}

struct InfoItemListView_Previews: PreviewProvider {
    static var previews: some View {
        InfoItemListView(item: InfoItem(title: "Test", body: "Test", infoType: "urgent"))
    }
}
