import SwiftUI
import CoreData
import os.log
import SDWebImageSwiftUI

struct PartnerLogoView: View {
    var partner: Partner
    
    var body: some View {
        VStack {
            if (partner.isSVG) {
                WebImage(url: partner.wrappedLogo, options: [], context: [.imageThumbnailPixelSize : CGSize.zero])
                    .placeholder {ProgressView()}
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        self.tapped()
                    }
            } else {
                AsyncImage(url: partner.wrappedLogo, content: { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .failure:
                        Color.red
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                self.tapped()
                            }
                        
                        
                    @unknown default:
                        fatalError()
                    }
                    
                }

                )

            }
        }
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
