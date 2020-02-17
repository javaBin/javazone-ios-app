import SwiftUI

struct SessionItemView: View {
    @ObservedObject var session: Session
    
    var body: some View {
        HStack {
            VStack {
                Text(session.fromTime()).font(.caption)
                Text(session.toTime()).font(.caption)
                if (session.lightningTalk) {
                    Image(systemName: "bolt")
                }
            }
            VStack(alignment: .leading) {
                if (session.title != nil) {
                    Text(session.wrappedTitle).font(.body)
                }
                HStack {
                    if (session.room != nil) {
                        Text(session.wrappedRoom).font(.caption)
                    }
                    /*
                    Text(session.speakerNames()).font(.caption)
                    */
                }
            }
            Spacer()
            FavouriteToggleView(favourite: $session.favourite)
        }
    }
}
