import SwiftUI
import WaterfallGrid

struct PartnerListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Partner.getPartners()) var partners: FetchedResults<Partner>

    @State private var isRefreshing = false
    @State private var isShowingRefreshAlert = false
    @State private var refreshAlertTitle = ""
    @State private var refreshAlertMessage = ""
    @State private var refreshFatal = false
    @State private var refreshFatalMessage = ""

    var cols : Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
           return 6
        }
        
        return 3
    }
    
    var body: some View {
        VStack {
            Text("Partner List")
            WaterfallGrid(partners.shuffled(), id: \.self) { partner in
                PartnerLogoView(partner: partner)
            }
            .gridStyle(columns: cols, spacing: 10)
            .padding()
            .onAppear(perform: {
                self.refreshPartners()
            })
            .alert(isPresented: $isShowingRefreshAlert) {
                Alert(title: Text(self.refreshAlertTitle),
                      message: Text(self.refreshAlertMessage),
                      dismissButton: Alert.Button.default(
                        Text("OK"), action: {
                            if (self.refreshFatal) {
                                fatalError(self.refreshFatalMessage)
                            }
                            
                            self.refreshAlertMessage = ""
                            self.refreshAlertTitle = ""
                            self.refreshFatalMessage = ""
                            self.refreshFatal = false
                      }
                    )
                )
            }
            Spacer()
        }
    }
    
    func refreshPartners() {
         PartnerService.refresh { (status, message, logMessage) in
            if (status == .Fail) {
                self.refreshFatal = false
                self.refreshAlertTitle = "Refresh failed"
                self.refreshAlertMessage = message
                self.refreshFatalMessage = ""
                self.isShowingRefreshAlert = true
            }
            
            if (status == .Fatal) {
                self.refreshFatal = true
                self.refreshAlertTitle = "Refresh failed"
                self.refreshAlertMessage = message
                self.refreshFatalMessage = logMessage
                self.isShowingRefreshAlert = true
            }
            
            self.isRefreshing = false
        }
    }
}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
