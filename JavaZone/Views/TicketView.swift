import SwiftUI
import CodeScanner

struct TicketView: View {
    @State private var scannedData = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Ticket View")
                Text(scannedData)
    
                NavigationLink(destination: ScannerView(data: $scannedData)) {
                    Text("Scan")
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
