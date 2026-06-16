import Foundation
import os.log

@Observable
@MainActor
final class InfoViewModel {
    private let logger = Logger(subsystem: Logger.subsystem, category: "InfoViewModel")

    var items: [InfoItem] = [InfoItem(title: "Wi-Fi - SSID: JavaZone", body: nil, infoType: nil)]
    var shortItems: [InfoItem] = []
    var longItems: [InfoItem] = []
    var fetchingItems = true

    private var lastUpdated = Date(timeIntervalSince1970: 0)

    func refreshItems(force: Bool = false) {
        guard force || abs(lastUpdated.diffInSeconds(date: Date())) > 5 * 60 else { return }
        logger.debug("Cache old — refreshing info")

        Task {
            do {
                let remoteInfo = try await InfoService.refresh()
                let newItems = remoteInfo.map { item in
                    InfoItem(
                        title: item.title,
                        body: item.body,
                        infoType: item.infoType,
                        urlTitle: item.url?.title,
                        url: item.url?.url
                    )
                }
                lastUpdated = Date()
                items = newItems
                shortItems = newItems.filter(\.isShort)
                longItems = newItems.filter { !$0.isShort }
                fetchingItems = false
            } catch {
                logger.debug("Unable to refresh info: \(error, privacy: .public)")
            }
        }
    }
}
