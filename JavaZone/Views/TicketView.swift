import SwiftUI
import CodeScanner

struct TicketView: View {
    @State private var scannedData = "Scanned data will go here"
    @State private var image : Image = Image(systemName: "qrcode")
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Scanned data")
                
                Text(scannedData)
                    .font(.headline)
    
                Spacer()

                NavigationLink(destination: ScannerView(data: $scannedData)) {
                    Text("Scan")
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
            .navigationBarTitle(Text("Ticket"), displayMode: .inline)
            .onAppear {
                if let qrImage = self.scannedData.generateQRCode() {
                    self.image = Image(uiImage: qrImage)
                }
            }
        }
    }
}

struct TicketView_Previews: PreviewProvider {
    static var previews: some View {
        TicketView()
    }
}
