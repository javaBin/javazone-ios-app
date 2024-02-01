import SwiftUI

struct DayPicker: View {
    @Binding var selectorIndex: Int

    var config: Config {
        Config.sharedConfig
    }

    var body: some View {
        Picker("", selection: $selectorIndex) {
            Text(config.dates[0]).tag(0)
            Text(config.dates[1]).tag(1)
            Text("Workshops").tag(2)
        }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal)
    }

}
