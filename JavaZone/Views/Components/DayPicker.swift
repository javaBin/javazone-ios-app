import SwiftUI

struct DayPicker: View {
    @Binding var selectorIndex: Int
    @Environment(AppConfig.self) private var appConfig

    var body: some View {
        Picker("Select day", selection: $selectorIndex) {
            Text(appConfig.dates[0]).tag(0)
            Text(appConfig.dates[1]).tag(1)
            Text("Workshops").tag(2)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}
