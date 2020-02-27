import SwiftUI
import CoreData
import RemoteImage
import os

struct DefaultPartnerImage: View {
    var message: String
    
    var body: some View {
        os_log("Image message %{public}@", log: .ui, type: .debug, message)

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
            if (imageUrl != nil) {
                PartnerImage(imageUrl: imageUrl!)
                    .grayscale(partner.contacted ? 0 : 0.8)
                    .opacity(partner.contacted ? 1 : 0.4)
                    .onTapGesture {
                        if (self.partner.wrappedSite != nil) {
                            UIApplication.shared.open(self.partner.wrappedSite!)
                        }
                    }
            } else {
                DefaultPartnerImage(message: "Partner \(partner.wrappedName) has no image")
            }
            Text(partner.wrappedName).font(.caption)
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
