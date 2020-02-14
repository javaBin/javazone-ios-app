import SwiftUI

struct SessionItemView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var session: Session
    
    var fromTime: String {
        if let date = session.startUtc {
            return date.asTime()
        }
        
        return "??"
    }

    var toTime: String {
        if let date = session.endUtc {
            return date.asTime()
        }
        
        return "??"
    }

    var body: some View {
        HStack {
            VStack {
                Text(fromTime)
                    .font(.caption)
                Text(toTime)
                    .font(.caption)
                if (session.isLightning()) {
                    Image(systemName: "bolt")
                }
            }
            VStack(alignment: .leading) {
                if (session.title != nil) {
                    Text(session.title!).font(.body)
                }
                HStack {
                    if (session.room != nil) {
                        Text(session.room!).font(.caption)
                    }
                    Text(session.speakerNames()).font(.caption)
                }
            }
            Spacer()
            FavouriteToggleView(session: session)
        }
    }
}
