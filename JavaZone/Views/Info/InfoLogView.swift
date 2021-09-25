import SwiftUI


struct InfoLogView: View {
    @StateObject var viewModel = InfoLogViewModel()
    
    var body: some View {
        VStack {
            if #available(iOS 15, *) {
                Text("If you are having problems then we might ask you for your logs.")
                    .padding(.horizontal)
                    .navigationTitle("Logs for the last 24 hrs")
                    .onAppear(perform: viewModel.refreshLogView)
                if (viewModel.fetchingLogs) {
                    ProgressView("Fetching last 24 hours of logs")
                } else {
                    Text("Simply copy/share the following:")
                        .padding(.horizontal).padding(.top, 20)
                    ScrollView(.vertical) {
                        Text("\(viewModel.logs)")
                            .textSelection(.enabled)
                            .padding(.horizontal)
                            .padding(.top, 20)
                    }
                }
                Spacer()
            } else {
                Text("Logs are only available on iOS 15 or later.")
            }
        }
    }
}

struct InfoLogView_Previews: PreviewProvider {
    static var previews: some View {
        InfoLogView()
    }
}
