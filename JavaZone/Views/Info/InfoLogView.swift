import SwiftUI

struct InfoLogView: View {
    @State private var viewModel = InfoLogViewModel()

    var body: some View {
        VStack {
            Text("If you are having problems then we might ask you for your logs.")
                .padding(.horizontal)
            if viewModel.fetchingLogs {
                ProgressView("Fetching last 24 hours of logs")
            } else {
                Text("Simply press and hold to copy the following:")
                    .padding(.horizontal).padding(.top, 20)
                ScrollView(.vertical) {
                    Text(viewModel.logs)
                        .textSelection(.enabled)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
            }
            Spacer()
        }
        .navigationTitle("Logs for the last 24 hrs")
        .task {
            viewModel.refreshLogView()
        }
    }
}

#Preview {
    InfoLogView()
}
