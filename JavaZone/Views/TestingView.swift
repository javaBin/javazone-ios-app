import SwiftUI

struct TestingView: View {
    var body: some View {
        VStack {
            Button(action: {
                SessionService.refresh()
            }){
                Text("Refresh")
            }
            Button(action: {
                SessionService.clear()
            }){
                Text("Clear")
            }
        }
    }
}
