import Foundation
import os

public struct InfoItem : Hashable {
    var title: String
    var body: String?
    var infoType: String?
    
    var isShort: Bool {
        return body == nil
    }
    
    var wrappedBody : String {
        return body ?? ""
    }
    
    var isUrgent: Bool {
        return (infoType ?? "") == "urgent"
    }
}

public class Info : ObservableObject {
    static let shared = Info()
    
    @Published public var infoItems:[InfoItem]
    private var lastUpdated: Date

    private init() {
        self.lastUpdated = Date(timeIntervalSince1970: 0)
        self.infoItems = [InfoItem(title: "Wi-Fi - SSID: JavaZone", body: nil, infoType: nil)]
    }
    
    private func difference(start: Date, end: Date) -> Int {
        os_log("Checking date difference between %{public}@ and %{public}@", log: .info, type: .debug, start as NSDate, end as NSDate)

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)

        return abs(dateComponents.second ?? 0)
    }

    
    public func update() {
        os_log("Update called", log: .info, type: .debug)

        if (difference(start: self.lastUpdated, end: Date()) > 5 * 60) {
            os_log("Cache old - update", log: .info, type: .debug)

            InfoService.refreshConfig { (remoteInfo) in
                os_log("Processing response", log: .info, type: .debug)

                var newItems : [InfoItem] = []
                
                remoteInfo.forEach { (remoteInfoItem) in
                    newItems.append(InfoItem(title: remoteInfoItem.title, body: remoteInfoItem.body, infoType: remoteInfoItem.infoType))
                }
                
                self.infoItems = newItems
                
                os_log("Saw %{public}d info items", log: .info, type: .debug, self.infoItems.count)
                
                self.lastUpdated = Date()
                
                os_log("Setting cache flag to %{public}@", log: .info, type: .debug, self.lastUpdated as NSDate)

            }
        }
    }
}
