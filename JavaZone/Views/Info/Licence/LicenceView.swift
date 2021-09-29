import SwiftUI

struct LicenceView: View {
    var licence : Licence
    
    var body: some View {
        ScrollView {
            VStack {
                if (licence.link != nil) {
                    ExternalLink(title: "\(licence.name)'s website", url: licence.link!).padding(.bottom, 20)
                }
                VStack(alignment: .leading) {
                    ForEach(licence.licence, id: \.self) { licenceLine in
                        Text(licenceLine)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            }.navigationTitle(licence.name)
        }
    }
}

struct LicenceView_Previews: PreviewProvider {
    static var previews: some View {
        LicenceView(licence: Licence(name: "Test", url: "https://java.no", licence: []))
    }
}
