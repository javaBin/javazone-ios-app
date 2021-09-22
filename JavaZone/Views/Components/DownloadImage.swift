import SwiftUI
import os.log

final class ImageLoader: ObservableObject {
    let logger = Logger(subsystem: Logger.subsystem, category: "ImageLoader")
    
    @Published var image: Image? = nil
        
    func load(name: String, fromURL url: String?) {
        logger.debug("Loading image - for \(name, privacy: .public)")

        DispatchQueue.global(qos: .userInitiated).async {
            guard let targetUrl = url else {
                self.logger.warning("Could not load image - for \(name, privacy: .public) - no url")
                return
            }
            guard let uiImage = ImageService.fetchImage(name: name, imageUrl: targetUrl) else {
                self.logger.warning("No image loaded - for \(name, privacy: .public) and url \(targetUrl, privacy: .public)")
                return
            }
                
            DispatchQueue.main.async {
                self.logger.debug("Image retrieved - for \(name, privacy: .public) and url \(targetUrl, privacy: .public)")
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}

struct DownloadImageWrapper: View {
    var image: Image?
    
    var body: some View {
        image?.resizable() ?? Image(systemName: "person.3.fill").resizable()
    }
}

struct DownloadImage: View {
    @StateObject private var imageLoader = ImageLoader()
    
    var name: String
    var urlString: String?
    
    var body: some View {
        DownloadImageWrapper(image: imageLoader.image)
            .onAppear { imageLoader.load(name: name, fromURL: urlString) }
    }
}
