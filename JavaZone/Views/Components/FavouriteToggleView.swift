import SwiftUI

struct FavouriteToggleView: View {
    @Binding var favourite: Bool
    
    var body: some View {
        Image(systemName: favourite == true ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.plus").resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0).onTapGesture {
                    self.favourite.toggle()
        }
    }
}

struct FavouriteToggleView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteToggleView(favourite: .constant(false))
    }
}
