import SwiftUI

struct PartnersView: View {
    @State private var selectorIndex = 1
    
    var body: some View {
            VStack {
                Text("Partners").font(.headline)
                #if PARTNERTABS
                Picker("", selection: $selectorIndex) {
                    Text("My Pass").tag(0)
                    Text("Partners").tag(1)
                    Text("Rules").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                #endif

                if (selectorIndex == 0) {
                    PartnerBadgeView()
                }
                if (selectorIndex == 1) {
                    PartnerListView()
                }
                if (selectorIndex == 2) {
                    PartnerRuleView()
                }

                Spacer()
        }
    }
}

struct PartnersView_Previews: PreviewProvider {
    static var previews: some View {
        PartnersView()
    }
}
