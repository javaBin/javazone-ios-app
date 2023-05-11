import SwiftUI

struct PartnerListView: View {
    @StateObject private var viewModel = PartnerViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.displayPartners, id: \.self) { partner in
                        PartnerLogoView(partner: partner)
                    }
                }.padding()
            }
            .refreshable {
                await self.viewModel.refreshPartners()
            }
            .onAppear(perform: {
                Task {
                    await self.viewModel.refreshPartners()
                }
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
        .background(Color(red: 0.17, green: 0.68, blue: 0.84))
    }
}

struct PartnerListView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerListView()
    }
}
