import SwiftUI

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
    }
}

struct LicenceListView_Previews: PreviewProvider {
    static var previews: some View {
        LicenceListView()   
    }
}
