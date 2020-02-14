//

import SwiftUI

struct SessionItemView: View {
    var session: Session
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(formatDateAsTime(date: session.startUtc))
                Text(formatDateAsTime(date: session.endUtc))
            }
            VStack(alignment: .leading) {
                Text(session.title!)
                Text(session.room!)
            }
            Spacer()
            Image(systemName: session.favourite == true ? "heart.fill" : "heart")
            Text(">").onAppear {
                print(self.session)
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

