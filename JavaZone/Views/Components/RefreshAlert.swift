import SwiftUI

struct RefreshAlert {
    @Binding var refreshAlertTitle : String
    @Binding var refreshAlertMessage : String
    @Binding var refreshFatal : Bool
    @Binding var refreshFatalMessage : String

    var alert: Alert {
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
}
