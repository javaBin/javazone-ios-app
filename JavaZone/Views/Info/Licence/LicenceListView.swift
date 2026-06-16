import SwiftUI

struct LicenceListView: View {
    @State private var viewModel = LicenceViewModel()

    var body: some View {
        List {
            ForEach(viewModel.licences, id: \.self) { licence in
                NavigationLink(destination: LicenceView(licence: licence)) {
                    Text(licence.name)
                }
            }
        }
        .navigationTitle("Licences")
        .task {
            viewModel.load()
        }
    }
}

#Preview {
    LicenceListView()
}
