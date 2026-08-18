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

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Capsule())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32.0, height: 32.0)
            } else {
                DefaultSpeakerImage()
            }
        }
        .task(id: avatarUrl) {
            image = await AvatarCache.shared.image(for: avatarUrl)
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
                        .accessibilityHidden(true)
                } else {
                    DefaultSpeakerImage()
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading) {
                    Text(speaker.wrappedName)
                        .textSelection(.enabled)
                        .font(.headline)
                    if let twitterUrl = speaker.wrappedTwitterUrl {
                        ExternalLink(
                            title: "@\(speaker.wrappedTwitter)",
                            url: twitterUrl,
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
    // swiftlint:disable:next force_try
    let container = try! ModelContainer(
        for: Session.self, SessionBody.self, Speaker.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let speaker = Speaker(name: "Test Speaker", bio: "Test bio")
    SpeakerItemView(speaker: speaker)
        .modelContainer(container)
}
