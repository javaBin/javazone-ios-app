import SwiftUI
import CodeScanner
import os

struct ScannerView: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var data : String
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "Simulator Data") { result in
            switch result {
            case .success(let code):
                self.data = "\(code)"
                self.presentation.wrappedValue.dismiss()
            case .failure(let error):
                os_log("Failed to scan %{public}@", log: .scanner, error.localizedDescription)
                self.data = "\(error.localizedDescription)"
                self.presentation.wrappedValue.dismiss()
            }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(data: .constant("Test"))
    }
}
