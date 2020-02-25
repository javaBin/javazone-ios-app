import Foundation
import UIKit

extension String {
    func contains(_ candidate: String) -> Bool {
        self.range(of: candidate, options: .caseInsensitive) != nil
    }

    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
    
    func generateQRCode() -> UIImage? {
        var uiImage: UIImage?

        if let data = self.data(using: String.Encoding.ascii),
            let filter = CIFilter(name: "CIQRCodeGenerator",
                                 parameters: ["inputMessage": data,
                                              "inputCorrectionLevel": "H"]) {

            if let outputImage = filter.outputImage,
                let cgImage = CIContext().createCGImage(outputImage,
                                                        from: outputImage.extent) {
                
                let size = CGSize(width: outputImage.extent.width * 7.0,
                                  height: outputImage.extent.height * 7.0)
                
                UIGraphicsBeginImageContext(size)

                if let context = UIGraphicsGetCurrentContext() {
                    context.interpolationQuality = .none
                    context.draw(cgImage,
                                 in: CGRect(origin: .zero,
                                            size: size))
                    uiImage = UIGraphicsGetImageFromCurrentImageContext()
                }

                UIGraphicsEndImageContext()
            }
        }

        return uiImage
    }
}

