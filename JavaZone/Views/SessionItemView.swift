import SwiftUI

struct SessionItemView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var session: Session
    
    var body: some View {
        HStack {
            VStack {
                Text(formatDateAsTime(date: session.startUtc))
                    .font(.caption)
                Text(formatDateAsTime(date: session.endUtc))
                    .font(.caption)
                if (session.isLightning()) {
                    Image(systemName: "bolt")
                }
            }
            VStack(alignment: .leading) {
                Text(session.title!).font(.body)
                HStack {
                    Text(session.room!).font(.caption)
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

func formatDateAsTime(date: Date?) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    if let date = date {
        return dateFormatter.string(from: date)
    }
    
    return "??"
}

