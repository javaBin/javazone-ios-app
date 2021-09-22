import UIKit
import os.log
import SVGKit

class ImageService {
    static let logger = Logger(subsystem: Logger.subsystem, category: "ImageService")
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    static func targetUrl(name: String?, ext: String) -> URL? {
        if let slug = name?.slug() {
            return getDocumentsDirectory().appendingPathComponent(slug).appendingPathExtension(ext)
        }
        
        return nil
    }
    
    static func fetchImage(name: String, imageUrl: String?) -> UIImage? {
        if let targetUrl = self.targetUrl(name: name, ext: "png"), let imageUrlString = imageUrl, let url = URL(string: imageUrlString) {
            var imageData : Data? = nil

            do {
                let absUrl = url.absoluteString
                
                self.logger.debug("Fetch image - getting as image for \(absUrl, privacy: .public)")
                
                let imageExt = url.pathExtension

                if (imageExt == "svg") {
                    self.logger.debug("SVG image - for \(absUrl, privacy: .public)")

                    let svgImage = SVGKImage(contentsOf: url)
                    
                    if let image = svgImage?.uiImage {
                        self.logger.debug("Fetch image - saving data to \(targetUrl, privacy: .public)")

                        if let pngData = image.pngData() {
                            try pngData.write(to: targetUrl)
                            imageData = pngData
                        }
                    } else {
                        self.logger.debug("Could not get image from SVG - for \(absUrl, privacy: .public)")
                    }
                } else {
                    self.logger.debug("Fetch image - fetching data for \(absUrl, privacy: .public)")

                    let data = try Data(contentsOf: url)

                    if let image = UIImage(data: data), let pngData = image.pngData() {
                        self.logger.debug("Fetch image - saving data to \(targetUrl, privacy: .public)")
                        try pngData.write(to: targetUrl)
                        imageData = pngData
                    }
                }
            } catch {
                self.logger.error("Could not save image from url \(error.localizedDescription, privacy: .public), \(url.absoluteString, privacy: .public)")
            }

            if let imageData = imageData {
                return UIImage(data: imageData)
            }

            self.logger.warning("Download of image \(url.absoluteString, privacy: .public) was empty")
        }
        
        return nil
    }
}
