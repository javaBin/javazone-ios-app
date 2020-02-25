import SwiftUI
import WaterfallGrid

struct PartnerListView: View {
    var body: some View {
        VStack {
            Text("Partner List")
            WaterfallGrid((0..<20), id: \.self) { index in
                Image(systemName: "\(index).circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.black)
            }
            .gridStyle(columns: 3, spacing: 10)
            .padding()
            Spacer()
        }
    }
}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
