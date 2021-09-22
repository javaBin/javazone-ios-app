import SwiftUI
import CoreData
import os.log

struct PartnerLogoView: View {
    @ObservedObject var partner: Partner
    
    var body: some View {
        VStack {
            DownloadImage(name: partner.wrappedName, urlString: ImageService.targetUrl(name: partner.name, ext: "png")?.absoluteString)
                .onTapGesture {
                    if (self.partner.wrappedSite != nil) {
                        UIApplication.shared.open(self.partner.wrappedSite!)
                    }
                }
        }
        .background(Color(red: 0.17, green: 0.68, blue: 0.84))
        .cornerRadius(8)
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
