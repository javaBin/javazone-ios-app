import SwiftUI

struct LicenceView: View {
    var licence : Licence
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Copyright (c)")
                    Text(licence.copyright.date)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .padding(.top, 20)

                HStack {
                    Text("Holder: ")
                    if (licence.copyright.link != nil) {
                        ExternalLink(title: licence.copyright.holder, url: licence.copyright.link!)
                    } else {
                        Text(licence.copyright.holder)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 20)

                if (licence.link != nil) {
                    HStack {
                        Text("Website: ")
                        ExternalLink(title: licence.name, url: licence.link!)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }

                VStack(alignment: .leading) {
                    ForEach(licence.licence, id: \.self) { licenceLine in
                        Text(licenceLine)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        Spacer()
                    }
                }
            }.navigationTitle(licence.name)
        }
    }
}

struct LicenceView_Previews: PreviewProvider {
    static var previews: some View {
        LicenceView(licence: Licence(name: "Test", url: "https://java.no", copyright: Copyright(date: "2000", holder: "javaBin", contact: "https://www.java.no"), licence: []))
    }
}
