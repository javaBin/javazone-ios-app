import SwiftUI
import WaterfallGrid
import os

struct PartnerListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Partner.getPartners()) var partners: FetchedResults<Partner>

    @State private var isShowingRefreshAlert = false
    @State private var refreshFatal = false
    @State private var refreshFatalMessage = ""
    
    @State private var showingScanSheet = false
    
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    private var isPortrait : Bool { UIDevice.current.orientation.isPortrait }
    
    private var hasBadge : Bool {
        (UserDefaults.standard.object(forKey: "CurrentBadge") as? String) != nil
    }
    
    // TODO - can we get info on screen size here? Calculate out from that?
    private var cols : Int {
        if idiom == .pad {
            if (isPortrait == true) {
                return 4
            } else {
                return 7
            }
        } else {
            if (isPortrait == true) {
                return 3
            } else {
                return 4
            }
        }
    }
    
    private var uncontacted : Int {
        self.partners.filter { (partner) -> Bool in
            partner.contacted == false
        }.count
    }
    
    var body: some View {
        VStack {
            if (hasBadge) {
                if (uncontacted == 0) {
                    VStack {
                        Text("Congratulations!").font(.title)
                        Text("You have collected them all").font(.caption)
                        Text("Come show us at the javaBin stand to enter the prize draw").font(.caption)
                    }
                } else {
                    HStack {
                        Text("Partner List").onTapGesture(count: 3) {
                            self.refreshPartners(force: true)
                        }
                        Spacer()
                        HStack {
                            Text("Scan")
                            Image(systemName: "qrcode")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }.onTapGesture {
                            self.showingScanSheet = true
                        }.sheet(isPresented: $showingScanSheet) {
                            ScannerView(simulatorData: PartnerService.TestData.partner, data: Binding(
                                get: { "" },
                                set: { (newVal) in
                                    self.partnerScan(value: newVal)
                                }
                            ))
                        }
                    }.padding()
                }
            }
            
            ScrollView {
                WaterfallGrid(partners.shuffled(), id: \.self) { partner in
                    PartnerLogoView(partner: partner, hasBadge: self.hasBadge)
                }
                .gridStyle(columns: cols, spacing: 10)
                .padding()
                .onAppear(perform: {
                    self.refreshPartners(force: false)
                })
            }
            .alert(isPresented: $isShowingRefreshAlert) {
                RefreshAlert(
                    refreshAlertTitle: $alertTitle,
                    refreshAlertMessage: $alertMessage,
                    refreshFatal: $refreshFatal,
                    refreshFatalMessage: $refreshFatalMessage
                ).alert
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text(self.alertTitle),
                      message: Text(self.alertMessage),
                      dismissButton: .default(Text("OK"))
                    )
            }
            Spacer()
        }
    }
    
    func refreshPartners(force: Bool) {
        PartnerService.refresh(force: force) { (status, message, logMessage) in
            
            // If we fail to fetch but have partners _ this list changes so rarely that we ignore and continue.
            if (status == .Fail && self.partners.count == 0) {
                self.refreshFatal = false
                self.alertTitle = "Refresh failed"
                self.alertMessage = message
                self.refreshFatalMessage = ""
                self.isShowingRefreshAlert = true
            }
            
            if (status == .Fatal) {
                self.refreshFatal = true
                self.alertTitle = "Refresh failed"
                self.alertMessage = message
                self.refreshFatalMessage = logMessage
                self.isShowingRefreshAlert = true
            }
        }
    }
    
    func partnerScan(value: String) {
        os_log("Scanned badge", log: .ui, type: .debug)
        
        if let data = value.data(using: .utf8) {
            let decoder = JSONDecoder()

            if let partner = try? decoder.decode(ScannedPartner.self, from: data) {
                os_log("Scanned partner - decode OK", log: .ui, type: .info)

                PartnerService.contact(partner: partner)
            } else {
                os_log("Could not decode scanned partner", log: .ui, type: .error)
            }
        } else {
            os_log("Could not get scanned partner", log: .ui, type: .error)
        }
    }
}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
