//
//  TrackingView.swift
//  JavaZone
//
//  Created by Chris Searle on 25/08/2023.
//  Copyright © 2023 Chris Searle. All rights reserved.
//

import SwiftUI

struct TrackingView: View {
    var body: some View {
        VStack {
            Text("We use Flurry for application analytics and crash logging.")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationTitle(Text("Crash Logging/Analytics"))
                .navigationBarTitleDisplayMode(.inline)
            Text("We do NOT collect any personally identifying information.")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("What do we actually collect?")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .italic()
            Text("We collect crash logs if the application crashes.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("We collect timing for actions that pull down data from JavaZone (for example sessions).")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("We collect error logs when something goes wrong.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Text("We collect simple counting events for which pages are displayed.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            Spacer()
        }

    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
}
