import SwiftUI
import WaterfallGrid
import os
import simd

struct PartnerListView: View {
    @StateObject private var viewModel = PartnerViewModel()

    @State private var refreshFatal = false

    @State private var alertItem : AlertItem?
    
    @State private var showingScanSheet = false

    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    private var isPortrait : Bool { UIDevice.current.orientation.isPortrait }
    
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
    
    var body: some View {
        VStack {
            ScrollView {
                WaterfallGrid(viewModel.displayPartners, id: \.self) { partner in
                    PartnerLogoView(partner: partner)
                }
                .gridStyle(columns: cols, spacing: 10)
                .padding()
                .onAppear(perform: {
                    self.refreshPartners(force: false)
                })
            }
            .alert(item: $alertItem) { alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: Alert.Button.default(
                        alertItem.buttonTitle,
                        action: {
                            AlertContext.processAlertItem(alertItem: alertItem)
                        }
                    )
                )
            }
            Spacer()
        }
    }

    func refreshPartners(force: Bool) {
        PartnerService.refresh(force: force) { (status, message, logMessage) in
            
            // If we fail to fetch but have partners _ this list changes so rarely that we ignore and continue.
            if (status == .Fail && self.viewModel.partners.count == 0) {
                self.alertItem = AlertContext.build(title: "Refresh failed", message: message, buttonTitle: "OK")
            }
            
            if (status == .Fatal) {
                self.alertItem = AlertContext.buildFatal(title: "Refresh failed", message: message, buttonTitle: "OK", fatalMessage: logMessage)
            }
        }
    }
}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
