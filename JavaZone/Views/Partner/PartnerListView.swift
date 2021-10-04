import SwiftUI
import WaterfallGrid

struct PartnerListView: View {
    @StateObject private var viewModel = PartnerViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                WaterfallGrid(viewModel.displayPartners, id: \.self) { partner in
                    PartnerLogoView(partner: partner)
                }
                .gridStyle(columns: viewModel.cols, spacing: 10)
                .padding()
            }
            .onAppear(perform: {
                self.viewModel.refreshPartners()
            })
            .onRotate(perform: { orientation in
                viewModel.setOrientation(orientation)
            })
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: Alert.Button.default(
                        alertItem.buttonTitle,
                        action: {
                            AlertContext.processAlertItem(alertItem: alertItem)
                        }
                    )
                )
            }
            Spacer()
        }
    }


}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
