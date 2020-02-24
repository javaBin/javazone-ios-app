import Foundation
import os

public struct InfoItem : Hashable {
    var title: String
    var body: String
}

public class Info : ObservableObject {
    static let shared = Info()
    
    @Published public var infoItems:[InfoItem]
    private var lastUpdated: Date

    private init() {
        self.lastUpdated = Date(timeIntervalSince1970: 0)
        self.infoItems = []
    }
    
    private func difference(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.second], from: start, to: end)

        return abs(dateComponents.second ?? 0)
    }

    
    public func update() {
        if (difference(start: self.lastUpdated, end: Date()) > 5 * 60) {
            InfoService.refreshConfig { (remoteInfo) in
                var newItems : [InfoItem] = []
                
                remoteInfo.forEach { (remoteInfoItem) in
                    newItems.append(InfoItem(title: remoteInfoItem.title, body: remoteInfoItem.body))
                }
                
                self.infoItems = newItems
                
                self.lastUpdated = Date()
            }
        }
    }
}
