//

import SwiftUI

struct PartnerBadgeView: View {
    @State private var scannedData = ""
    
    @State private var showingScanSheet = false

    var body: some View {
        VStack {
            Text("Your Badge").font(.largeTitle).padding()
            
            if (self.scannedData == "") {
                Text("To take part in the partner game you need to scan your conference badge first.")

                Button("Scan Badge") {
                    self.showingScanSheet = true
                }.sheet(isPresented: $showingScanSheet) {
                    ScannerView(data: Binding(
                        get: { self.scannedData },
                        set: { (newVal) in
                            self.scannedData = newVal
                            // Here we can store the user's badge
                        }
                    ))
                }.padding()
            }
            
            if (self.scannedData != "") {
                Text("Your Details").font(.headline).padding()
                
                Text("Details of the scanned badge here")

                Button("Scan a new badge") {
                    self.showingScanSheet = true
                }.sheet(isPresented: $showingScanSheet) {
                    ScannerView(data: self.$scannedData)
                }.padding()
                
                Text("Scanning a new badge will reset the partner game.")

            }

            Spacer()
        }
    }
}

struct PartnerBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerBadgeView()
    }
}
