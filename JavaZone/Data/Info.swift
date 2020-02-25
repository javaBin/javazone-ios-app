import Foundation
import os

public struct InfoItem : Hashable {
    var title: String
    var body: String?
    var infoType: String?
    var urlTitle: String?
    var url: String?
    
    var isShort: Bool {
        return body == nil
    }
    
    var wrappedBody : String {
        return body ?? ""
    }
    
    var wrappedLinkTitle : String {
        return urlTitle ?? ""
    }

    var wrappedLink : URL? {
        if let url = self.url {
            return URL(string:url)
        }
        
        return nil
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
    
    public func update(force: Bool, callback: (() -> Void)?) {
        os_log("Update called", log: .info, type: .debug)

        if (force || abs(self.lastUpdated.diffInSeconds(date: Date())) > 5 * 60) {
            os_log("Cache old - update", log: .info, type: .debug)

            InfoService.refreshConfig { (remoteInfo) in
                os_log("Processing response", log: .info, type: .debug)

                var newItems : [InfoItem] = []
                
                remoteInfo.forEach { (remoteInfoItem) in
                    newItems.append(InfoItem(title: remoteInfoItem.title, body: remoteInfoItem.body, infoType: remoteInfoItem.infoType, urlTitle: remoteInfoItem.url?.title, url: remoteInfoItem.url?.url))
                }
                
                self.infoItems = newItems
                
                os_log("Saw %{public}d info items", log: .info, type: .debug, self.infoItems.count)
                
                self.lastUpdated = Date()
                
                os_log("Setting cache flag to %{public}@", log: .info, type: .debug, self.lastUpdated as NSDate)

                if let callback = callback {
                    callback()
                }
            }
        }
    }
}
