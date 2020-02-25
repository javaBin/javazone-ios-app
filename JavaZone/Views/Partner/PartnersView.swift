import SwiftUI

struct PartnersView: View {
    @State private var selectorIndex = 0
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectorIndex) {
                    Text("Your Badge").tag(0)
                    Text("Partners").tag(1)
                    Text("Rules").tag(2)
                }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal)

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
            }.navigationBarTitle("Partners")
        }
    }
}

struct PartnersView_Previews: PreviewProvider {
    static var previews: some View {
        PartnersView()
    }
}
