import SwiftUI
import CodeScanner
import os

struct ScannerView: View {
    var simulatorData = "Scanner Data"
    
    @Environment(\.presentationMode) var presentation
    
    @Binding var data : String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Scan").font(.title).padding(.leading, 16.0)
                Spacer()
                Image(systemName: "xmark.square")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        self.presentation.wrappedValue.dismiss()
                    }
            }.padding()
            CodeScannerView(codeTypes: [.qr], simulatedData: simulatorData) { result in
                switch result {
                case .success(let code):
                    self.data = "\(code)"
                    self.presentation.wrappedValue.dismiss()
                case .failure(let error):
                    os_log("Failed to scan %{public}@", log: .scanner, error.localizedDescription)
                    self.presentation.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView(data: .constant("Test"))
    }
}
