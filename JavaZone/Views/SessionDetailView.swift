import SwiftUI
import RemoteImage

struct SessionDetailView: View {
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
    
    var title: String {
        return "\(session.room ?? "") - \(fromTime) - \(toTime)"
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack{
                    FavouriteToggleView(favourite: $session.favourite)
                    Text(session.title ?? "").font(.headline).padding(.leading).padding(.trailing)
                }
                VStack(alignment: .leading) {
                    Text("Abstract").font(.title).padding(.bottom, 15)
                    if (session.abstract != nil) {
                        Text(session.abstract!).font(.body).padding(.bottom, 20)
                    }
                    Text("Intended Audience").font(.title).padding(.bottom, 15)
                    if (session.audience != nil) {
                        Text(session.audience!).font(.body).padding(.bottom, 20)
                    }
                    Text("Speakers").font(.title).padding(.bottom, 15)
                    ForEach(Array(session.speakers) ) { speaker in
                        VStack(alignment: .leading) {
                            HStack {
                                if (speaker.avatar != nil) {
                                    RemoteImage(type: .url(speaker.getAvatarUrl()!), errorView: { error in
                                        Image(systemName: "person")
                                    }, imageView: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32.0, height: 32.0)
                                    }, loadingView: {
                                        Image(systemName: "person")
                                    })
                                }
                                Text(speaker.name).font(.headline).padding(.bottom, 15)
                            }
                            if (speaker.bio != nil) {
                                Text(speaker.bio!).font(.body).padding(.bottom, 15)
                            }
                        }
                    }
                }.padding()
                
                Spacer()
            }
        }
        .navigationBarTitle(Text(title), displayMode: .inline)
    }
}
