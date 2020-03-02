import SwiftUI
import Contacts
import os

struct PartnerBadgeView: View {
    @State private var scannedData = ""
    
    @State private var showingScanSheet = false
    @State private var image : Image = Image(systemName: "qrcode")
    
    @State private var name: String = ""
    @State private var role: String = ""
    @State private var company: String = ""

    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            if (self.scannedData == "") {
                Text("Your Badge")
                    .font(.largeTitle)
                    .padding(.bottom)

                Text("To take part in the partner game you need to scan your conference badge first.")
                    .font(.body)
                    .multilineTextAlignment(.center)

                Button(action: {
                    self.showingScanSheet = true
                }) {
                    HStack {
                        Image(systemName: "qrcode")
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text("Scan Badge")
                    }
                }.sheet(isPresented: $showingScanSheet) {
                    ScannerView(data: Binding(
                        get: { self.scannedData },
                        set: { (newVal) in
                            self.newQrCode(value: newVal)
                        }
                    ))
                }.padding()

                Spacer()
            }
            
            if (self.scannedData != "") {
                Text(self.name)
                    .font(.title)
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                
                Text(self.role)
                    .font(.headline)
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                
                Text(self.company)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Spacer()

                self.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 203, height: 203)
                    .background(Color.black)
                    .onAppear {
                        if let qrImage = self.scannedData.generateQRCode() {
                            self.image = Image(uiImage: qrImage)
                        }
                    }
                
                Spacer()
                
                Button(action: {
                    self.showingScanSheet = true
                }) {
                    HStack {
                        Image(systemName: "qrcode")
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text("Scan a new badge")
                    }
                }.sheet(isPresented: $showingScanSheet) {
                    ScannerView(data: Binding(
                        get: { self.scannedData },
                        set: { (newVal) in
                            self.newQrCode(value: newVal)
                        }
                    ))
                }.padding()
                
                Text("Scanning a new badge will reset the partner game.")
                    .font(.body)

            }
        }
        .padding()
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(self.alertTitle),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text("OK"))
                )
        }
    }
    
    func newQrCode(value: String) {
        os_log("Scanned badge", log: .ui, type: .debug)

        if let data = value.data(using: .utf8) {
            do {
                self.alertTitle = ""
                self.alertMessage = ""
                self.isShowingAlert = false
                
                let cards = try CNContactVCardSerialization.contacts(with: data)
            
                os_log("Saw %{public}d cards", log: .ui, type: .debug, cards.count)
                
                if let badge = cards.first {
                    self.name = [badge.givenName, badge.familyName]
                        .filter({ (str) -> Bool in
                            str != ""
                        })
                        .joined(separator: " ")
                    
                    self.role = badge.jobTitle != "" ? badge.jobTitle : ""
                    self.company = badge.organizationName != "" ? badge.organizationName : ""
                    
                    self.scannedData = value
                    
                    PartnerService.clearContacted()
                }
            } catch {
                os_log("Failed to process badge %{public}@", log: .ui, type: .error, error.localizedDescription)
                
                self.scannedData = ""
                self.name = ""
                self.role = ""
                self.company = ""
                
                self.alertTitle = "Unable to scan"
                self.alertMessage = "Unable to scan badge"
                self.isShowingAlert = true
            }
        } else {
            os_log("Could not get decode badge", log: .ui, type: .error)
        }
    }
}

struct PartnerBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerBadgeView()
    }
}
