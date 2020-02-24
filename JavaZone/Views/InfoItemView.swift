//

import SwiftUI

struct InfoItemView: View {
    var title: String
    var text: String
    
    var body: some View {
        VStack {
            Text(text)
                .navigationBarTitle(title)
            Spacer()
        }
    }
}

struct InfoItemView_Previews: PreviewProvider {
    static var previews: some View {
        InfoItemView(title: "Test", text: "Test")
    }
}
