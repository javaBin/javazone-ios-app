import SwiftUI
import Flurry_iOS_SDK

struct LicenceListView: View {
    @StateObject var viewModel = LicenceViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.licences, id: \.self) { licence in
                NavigationLink(destination: LicenceView(licence: licence)) {
                    Text(licence.name)
                }
            }
        }
        .navigationTitle("Licences")
        .onAppear {
            Flurry.log(eventName: "ScreenView_LicenceList")
        }
    }
}

struct LicenceListView_Previews: PreviewProvider {
    static var previews: some View {
        LicenceListView()
    }
}
