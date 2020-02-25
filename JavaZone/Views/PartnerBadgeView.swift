//

import SwiftUI

struct PartnerBadgeView: View {
    @State private var scannedData = "Scanned data will go here"
    @State private var image : Image = Image(systemName: "qrcode")
    
    @State private var showingScanSheet = false

    var body: some View {
        VStack {
            Text("Scanned data")
            
            Text(scannedData)
                .font(.headline)

            Spacer()

            Button("Scan") {
                self.showingScanSheet = true
            }.sheet(isPresented: $showingScanSheet) {
                ScannerView(data: self.$scannedData)
            }
            
            Spacer()

            Text("Test QR Generator")

            Text("QR Code generated from the scanned data text")
                .font(.headline)
            
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 203, height: 203) // H quality QR is 29x29 - we are scaling by 7x
                .background(Color.black)
            
            Spacer()
        }
        .onAppear {
            if let qrImage = self.scannedData.generateQRCode() {
                self.image = Image(uiImage: qrImage)
            }
        }
    }
}

struct PartnerBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerBadgeView()
    }
}
