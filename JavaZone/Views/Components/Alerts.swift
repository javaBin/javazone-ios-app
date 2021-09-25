import SwiftUI

struct AlertItem : Identifiable {
    let id = UUID()
    
    var title: Text
    var message : Text
    var buttonTitle : Text
    
    var fatalMessage : String?
}

class AlertContext {
    static func build(title: String, message: String, buttonTitle: String) -> AlertItem {
        return AlertItem(title: Text(title), message: Text(message), buttonTitle: Text(buttonTitle), fatalMessage: nil)
    }

    static func buildFatal(title: String, message: String, buttonTitle: String, fatalMessage: String) -> AlertItem {
        return AlertItem(title: Text(title), message: Text(message), buttonTitle: Text(buttonTitle), fatalMessage: fatalMessage)
    }

    static func processAlertItem(alertItem : AlertItem) {
        if let fatalMessage = alertItem.fatalMessage {
            fatalError(fatalMessage)
        }
    }
}
