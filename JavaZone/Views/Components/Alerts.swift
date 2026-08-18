import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()

    var title: Text
    var message: Text
    var buttonTitle: Text
}

enum AlertContext {
    static func build(title: String, message: String, buttonTitle: String) -> AlertItem {
        AlertItem(title: Text(title), message: Text(message), buttonTitle: Text(buttonTitle))
    }
}
