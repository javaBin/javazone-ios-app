import SwiftUI
import Alamofire
import CoreData
import os.log

class PartnerService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "PartnerService")
    
    static let partnerStorage = PartnerStorage.shared
    
    static func refresh() async throws -> UpdateStatus {
        return try await withCheckedThrowingContinuation { continuation in
            refresh { result in
                continuation.resume(with: result)
            }
        }
    }
    
    static func refresh(_ onComplete: @escaping (Result<UpdateStatus, Error>) -> Void) {
        ConfigService.refreshConfig() {
            let config = Config.sharedConfig

            logger.info("Refreshing partners")

            let request = AF.request("\(config.web)api/partners")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            logger.debug("Fetching partners")
            
            request.responseDecodable(of: [RemotePartner].self, decoder: decoder) { (response) in
                if let error = response.error {
                    logger.error("Unable to fetch partners \(error.localizedDescription, privacy: .public)")
                    
                    onComplete(.failure(ServiceError(status: .Fail, message: "Could not download partners, please try again")))
                   
                    return
                }
                
                guard let partners = response.value else {
                    logger.error("Unable to read partners")

                    onComplete(.failure(ServiceError(status: .Fail, message: "Could not download partners, please try again")))
                    
                    return
                }
                
                do {
                    logger.debug("Clearing old partners")
                    
                    try partnerStorage.clear()
                } catch {
                    logger.error("Could not clear partners \(error.localizedDescription, privacy: .public)")
                    
                    onComplete(.failure(ServiceError(status: .Fatal, message: "Issue in the data store - please delete and reinstall", detail: "Unable to clear partner data \(error)")))
                    
                    return
                }
                
                var newPartners : [Partner] = []
                
                partners.forEach { (remotePartner) in
                    if let url = remotePartner.url, let name = remotePartner.name, let logoUrl = remotePartner.logoUrl {
                        let partner = partnerStorage.add(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            partnerUrl: url.trimmingCharacters(in: .whitespacesAndNewlines),
                            logoUrl: logoUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        
                        newPartners.append(partner)
                    }
                }
                
                logger.debug("Saw \(newPartners.count, privacy: .public) new partners")
                
                do {
                    try partnerStorage.save()
                } catch {
                    logger.error("Could not save partners \(error.localizedDescription, privacy: .public)")

                    onComplete(.failure(ServiceError(status: .Fatal, message: "Issue in the data store - please delete and reinstall", detail: "Unable to save data - partners \(error)")))
                    
                    return
                }
                
                Date().save(key: "PartnerDate")
                
                onComplete(.success(.OK))
            }
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    static func targetUrl(name: String?) -> URL? {
        if let slug = name?.slug() {
            return getDocumentsDirectory().appendingPathComponent(slug).appendingPathExtension("png")
        }
        
        return nil
    }
}
