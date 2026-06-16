import SwiftUI
import SwiftData

struct DefaultSpeakerImage: View {
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32.0, height: 32.0)
    }
}

struct SpeakerImage: View {
    var avatarUrl: URL

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
                if let avatarUrl = speaker.wrappedAvatar {
                    SpeakerImage(avatarUrl: avatarUrl)
                } else {
                    DefaultSpeakerImage()
                }
                VStack(alignment: .leading) {
                    Text(speaker.wrappedName)
                        .textSelection(.enabled)
                        .font(.headline)
                    if speaker.twitter != nil {
                        ExternalLink(
                            title: "@\(speaker.wrappedTwitter)",
                            url: URL(string: "https://twitter.com/\(speaker.wrappedTwitter)")!,
                            image: ""
                        )
                    }
                }
            }
            if speaker.bio != nil {
                Text(speaker.wrappedBio)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding(.bottom, 15)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Session.self, Speaker.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let speaker = Speaker(name: "Test Speaker", bio: "Test bio", twitter: "@test")
    SpeakerItemView(speaker: speaker)
        .modelContainer(container)
}
