import SwiftUI

struct FavouriteToggleView: View {
    @Binding var favourite: Bool
    
    var body: some View {
        Image(systemName: favourite == true ? "heart.fill" : "heart").resizable()
            .frame(width: 32.0, height: 32.0).onTapGesture {
                    self.favourite.toggle()
        }
    }
}

struct FavouriteToggleView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteToggleView(favourite: .constant(false))
    }
}
