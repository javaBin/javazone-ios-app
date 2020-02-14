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
            Image(systemName: session.favourite == true ? "heart.fill" : "heart").resizable()
                .frame(width: 32.0, height: 32.0).onTapGesture {
                        self.session.favourite = !self.session.favourite
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print("Unable to toggle fav for \(self.session.sessionId)")
                    }
            }
        }
    }
}

struct SessionItemView_Previews: PreviewProvider {
    static var previews: some View {
        SessionItemView(session: Session())
    }
}


