import SwiftUI
import OSLog

class InfoViewModel: ObservableObject {
    @Published var items: [InfoItem] = [InfoItem(title: "Wi-Fi - SSID: JavaZone", body: nil, infoType: nil)] {
        willSet {
            shortItems = newValue.filter({$0.isShort})
            longItems = newValue.filter({!$0.isShort})
        }
    }

    @Published var shortItems: [InfoItem] = []
    @Published var longItems: [InfoItem] = []
    @Published var fetchingItems = true

    private var lastUpdated = Date(timeIntervalSince1970: 0)

    func refreshItems(force: Bool = false) {
        Logger.interaction.debug("InfoViewModel: refreshItems: Update called")

        if force || abs(self.lastUpdated.diffInSeconds(date: Date())) > 5 * 60 {
            Logger.interaction.debug("InfoViewModel: refreshItems: Cache old - update")

            Task {
                do {
                    let remoteInfo = try await InfoService.refresh()

                    Logger.interaction.debug("InfoViewModel: refreshItems: Processing response")

                    var newItems: [InfoItem] = []

                    remoteInfo.forEach { (remoteInfoItem) in
                        newItems.append(
                            InfoItem(
                                title: remoteInfoItem.title,
                                body: remoteInfoItem.body,
                                infoType: remoteInfoItem.infoType,
                                urlTitle: remoteInfoItem.url?.title,
                                url: remoteInfoItem.url?.url))
                    }

                    Logger.interaction.debug("InfoViewModel: refreshItems: Saw \(newItems.count) info items")

                    self.lastUpdated = Date()

                    Logger.interaction.debug("""
InfoViewModel: refreshItems: Setting cache flag to \(self.lastUpdated, privacy: .public)
"""
                    )

                    let completedItems = newItems

                    await MainActor.run {
                        self.items = completedItems
                        self.fetchingItems = false
                    }
                } catch {
                    Logger.interaction.debug("""
InfoViewModel: refreshItems: Unable to refresh info \(error, privacy: .public)
"""
                    )
                }
            }
        }
    }
}
