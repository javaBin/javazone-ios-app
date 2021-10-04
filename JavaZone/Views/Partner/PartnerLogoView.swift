import SwiftUI
import CoreData
import RemoteImage
import os.log

struct PartnerLogoView: View {
    var partner: Partner
    
    var body: some View {
        VStack {
            Image("partner_\(partner.wrappedName.slug())")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    self.tapped()
                }
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
        
        return PartnerLogoView(partner: partner)
    }
}
