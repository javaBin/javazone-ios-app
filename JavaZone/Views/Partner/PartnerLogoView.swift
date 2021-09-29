import SwiftUI
import CoreData
import RemoteImage
import os.log

struct DefaultPartnerImage: View {
    let logger = Logger(subsystem: Logger.subsystem, category: "DefaultPartnerImage")
    
    var message: String
    
    var body: some View {
        logger.debug("Image message \(message, privacy: .public)")
        
        return Image(systemName: "person.3.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct PartnerImage: View {
    var imageUrl : URL
    
    var body: some View {
        RemoteImage(type: .url(imageUrl), errorView: { error in
            DefaultPartnerImage(message: error.localizedDescription)
        }, imageView: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }, loadingView: {
            DefaultPartnerImage(message: "Loading")
        })
    }
}

struct PartnerLogoView: View {
    var partner: Partner
    
    var imageUrl: URL? {
        return PartnerService.getImageUrl(partner: partner)
    }
    
    var body: some View {
        VStack {
#if DOWNLOADPARTNERLOGOS
            if (imageUrl != nil) {
                PartnerImage(imageUrl: imageUrl!)
                    .onTapGesture {
                        self.tapped()
                    }
            } else {
                DefaultPartnerImage(message: "Partner \(partner.wrappedName) has no image")
            }
#else
            Image("partner_\(partner.wrappedName.slug())")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    self.tapped()
                }
#endif
        }
        .background(Color(red: 0.17, green: 0.68, blue: 0.84))
        .cornerRadius(8)
    }
    
    func tapped() {
        if (self.partner.wrappedSite != nil) {
            UIApplication.shared.open(self.partner.wrappedSite!)
        }
    }
}

struct PartnerLogoView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        let partner = Partner(context: moc)
        
        partner.name = "javaBin"
        partner.url = "https://java.no"
        partner.image = "https://www.java.no/img/duke/marius_duke.svg"
        
        return PartnerLogoView(partner: partner)
    }
}
