import SwiftUI

struct SpinnerView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var spinning = false
    
    var backgroundColor : Color {
        colorScheme == .light ? Color.black : Color.white
    }
    
    var foregroundColor: Color {
        colorScheme == .light ? Color.white : Color.black
    }
    
    var body: some View {
        ZStack {
            self.backgroundColor
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)   
            VStack {
                Image(systemName: "rays")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(self.foregroundColor)
                    .rotationEffect(.degrees(self.spinning ? 360 : 0))
                    .animation(
                        Animation
                            .linear(duration: 2)
                            .repeatForever(autoreverses: false)
                    )
                    .onAppear {
                        self.spinning.toggle()
                    }

                Text("Updating").foregroundColor(self.foregroundColor)
            }
        }
    }
}

struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            VStack {
                Text("Text 1")
                Text("Text 2")
                Text("Text 3")
                Spacer()
            }
            SpinnerView().environment(\.colorScheme, ColorScheme.light)
        }
    }
}
