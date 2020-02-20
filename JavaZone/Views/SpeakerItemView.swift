import SwiftUI
import RemoteImage
import CoreData

struct SpeakerItemView: View {
    var speaker: Speaker
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if (speaker.wrappedAvatar != nil) {
                    RemoteImage(type: .url(speaker.wrappedAvatar!), errorView: { error in
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32.0, height: 32.0)
                    }, imageView: { image in
                        image
                            .resizable()
                            .clipShape(Capsule())
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32.0, height: 32.0)
                    }, loadingView: {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32.0, height: 32.0)
                    })
                }
                VStack(alignment: .leading) {
                    Text(speaker.wrappedName).font(.headline)
                    if (speaker.twitter != nil) {
                        ExternalLink(title: "@\(speaker.wrappedTwitter)", url: URL(string: "https://twitter.com/\(speaker.wrappedTwitter)")!, image: false)
                    }
                }
            }
            if (speaker.bio != nil) {
                Text(speaker.wrappedBio).font(.body).padding(.bottom, 15)
            }
        }
    }
}

struct SpeakerItemView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        let speaker = Speaker(context: moc)
        
        speaker.name = "Test speaker"
        speaker.bio = "Test Bio - lots of uninteresting factoids"
        speaker.twitter = "@TestTwitter"
        
        return SpeakerItemView(speaker: speaker)
    }
}
