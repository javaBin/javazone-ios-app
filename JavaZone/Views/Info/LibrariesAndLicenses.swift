// Display used libraries with licence where available. If not - link to library

import SwiftUI

struct LibrariesAndLicenses: View {
    var body: some View {
        List {
            NavigationLink(destination: LicenceView(title: "Alamofire", link: URL(string: "https://github.com/Alamofire/Alamofire"), text: LicenceTexts.alamofire)) {
                Text("Alamofire")
            }
            NavigationLink(destination: LicenceView(title: "RemoteImage", link: URL(string: "https://github.com/crelies/RemoteImage"), text: LicenceTexts.remoteimage)) {
                Text("RemoteImage")
            }
            NavigationLink(destination: LicenceView(title: "SwiftUIRefresh", link: URL(string: "https://github.com/siteline/SwiftUIRefresh"), text: LicenceTexts.swiftuirefresh)) {
                Text("SwiftUIRefresh")
            }
            NavigationLink(destination: LicenceView(title: "SwiftUI-Introspect", link: URL(string: "https://github.com/siteline/SwiftUI-Introspect"), text: LicenceTexts.swiftuiintrospect)) {
                Text("SwiftUI-Introspect")
            }
            NavigationLink(destination: LicenceView(title: "SVGKit", link: URL(string: "https://github.com/SVGKit/SVGKit"), text: LicenceTexts.svgkit)) {
                Text("SVGKit")
            }
            NavigationLink(destination: LicenceView(title: "WaterfallGrid", link: URL(string: "https://github.com/paololeonardi/WaterfallGrid"), text: LicenceTexts.waterfallgrid)) {
                Text("WaterfallGrid")
            }
        }.navigationTitle("Libraries used")
    }
}

struct LibrariesAndLicenses_Previews: PreviewProvider {
    static var previews: some View {
        LibrariesAndLicenses()
    }
}

