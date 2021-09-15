import Foundation
import os.log

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
        Logger.info.debug("Update called")

        if (force || abs(self.lastUpdated.diffInSeconds(date: Date())) > 5 * 60) {
            Logger.info.debug("Cache old - update")

            InfoService.refreshConfig { (remoteInfo) in
                Logger.info.debug("Processing response")

                var newItems : [InfoItem] = []
                
                remoteInfo.forEach { (remoteInfoItem) in
                    newItems.append(InfoItem(title: remoteInfoItem.title, body: remoteInfoItem.body, infoType: remoteInfoItem.infoType, urlTitle: remoteInfoItem.url?.title, url: remoteInfoItem.url?.url))
                }
                
                self.infoItems = newItems
                
                Logger.info.debug("Saw \(self.infoItems.count) info items")
                
                self.lastUpdated = Date()
                
                Logger.info.debug("Setting cache flag to \(self.lastUpdated)")

                if let callback = callback {
                    callback()
                }
            }
        }
    }
}
