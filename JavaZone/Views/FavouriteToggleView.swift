//

import SwiftUI

struct FavouriteToggleView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var session: Session
    
    var body: some View {
        Image(systemName: session.favourite == true ? "heart.fill" : "heart").resizable()
            .frame(width: 32.0, height: 32.0).onTapGesture {
                    self.session.favourite = !self.session.favourite
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Unable to toggle fav for \(self.session.sessionId)")
                }
        }
    }
}
