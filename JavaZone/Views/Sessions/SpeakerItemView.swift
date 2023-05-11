import SwiftUI
 import CoreData

struct DefaultSpeakerImage: View {
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32.0, height: 32.0)
    }
}

struct SpeakerImage: View {
    var avatarUrl : URL
    
    var body: some View {
        AsyncImage(url: avatarUrl) { image in
            image
                .resizable()
                .clipShape(Capsule())
                .aspectRatio(contentMode: .fit)
                .frame(width: 32.0, height: 32.0)
        } placeholder: {
            DefaultSpeakerImage()
        }
    }
}

struct SpeakerItemView: View {
    var speaker: Speaker
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if (speaker.wrappedAvatar != nil) {
                    SpeakerImage(avatarUrl: speaker.wrappedAvatar!)
                } else {
                    DefaultSpeakerImage()
                }
                VStack(alignment: .leading) {
                    Text(speaker.wrappedName)
                        .copyable(speaker.wrappedName)
                        .font(.headline)
                    if (speaker.twitter != nil) {
                        ExternalLink(title: "@\(speaker.wrappedTwitter)", url: URL(string: "https://twitter.com/\(speaker.wrappedTwitter)")!, image: "")
                    }
                }
            }
            if (speaker.bio != nil) {
                Text(speaker.wrappedBio)
                    .font(.body)
                    .copyable(speaker.wrappedBio)
                    .padding(.bottom, 15)
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
