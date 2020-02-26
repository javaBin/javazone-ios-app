import SwiftUI
import CoreData
import RemoteImage
import os

struct DefaultPartnerImage: View {
    var message: String
    
    var body: some View {
        os_log("Image message %{public}@", log: .ui, type: .info, message)

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
    
    var body: some View {
        VStack {
            ZStack {
                if (partner.wrappedImage != nil) {
                    PartnerImage(imageUrl: partner.wrappedImage!)
                } else {
                    DefaultPartnerImage(message: "Partner \(partner.wrappedName) has no image")
                }
                if (partner.contacted) {
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32.0, height: 32.0)
                        .offset(x: 32, y: 32)
                        .foregroundColor(Color.yellow)
                        .shadow(color: Color.gray, radius: 3, x: 5, y: 5)
                }
            }
            Text(partner.wrappedName).font(.caption)
            Text(partner.wrappedUrl).font(.caption)
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
