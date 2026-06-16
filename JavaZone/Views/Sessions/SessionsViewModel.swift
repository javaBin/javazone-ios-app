import Foundation
import SwiftData
import os.log

@Observable
@MainActor
final class SessionsViewModel {
    private let logger = Logger(subsystem: Logger.subsystem, category: "SessionsViewModel")

    var isRefreshing = false
    var alertItem: AlertItem?

    func refresh(context: ModelContext, appConfig: AppConfig) async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await SessionService.refresh(context: context, appConfig: appConfig)
            UserDefaults.standard.set(Date(), forKey: "NSessionLastUpdate")
        } catch let error as SessionError {
            switch error {
            case .fail(let message):
                alertItem = AlertContext.build(title: "Refresh failed", message: message, buttonTitle: "OK")
            case .fatal(let message, let detail):
                alertItem = AlertContext.buildFatal(
                    title: "Refresh failed", message: message,
                    buttonTitle: "OK", fatalMessage: detail
                )
            }
        } catch {
            logger.debug("Unexpected refresh error: \(error, privacy: .public)")
        }
    }
}
