import SwiftUI
import WaterfallGrid
import os

struct PartnerListView: View {
    @StateObject private var viewModel = PartnerViewModel()

    @State private var refreshFatal = false

    @State private var isShowingRefreshAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var refreshFatalMessage = ""
    
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
            .alert(isPresented: $isShowingRefreshAlert) {
                RefreshAlert(
                    refreshAlertTitle: $alertTitle,
                    refreshAlertMessage: $alertMessage,
                    refreshFatal: $refreshFatal,
                    refreshFatalMessage: $refreshFatalMessage
                ).alert
            }
            Spacer()
        }
    }
    
    func refreshPartners(force: Bool) {
        PartnerService.refresh(force: force) { (status, message, logMessage) in
            
            // If we fail to fetch but have partners _ this list changes so rarely that we ignore and continue.
            if (status == .Fail && self.viewModel.partners.count == 0) {
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
}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
