import SwiftUI

struct TestingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Session.getAll()) var sessions:FetchedResults<Session>

    @State private var count = 0

    var body: some View {
        VStack {
            Button(action: {
                SessionService.refresh()
            }){
                Text("Refresh")
            }
            List {
                ForEach(self.sessions) { session in
                    Text(session.title!)
                }
            }
        }
    }
}

struct TestingView_Previews: PreviewProvider {
    static var previews: some View {
        TestingView()
    }
}
