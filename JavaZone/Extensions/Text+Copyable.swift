import SwiftUI

struct CopyableViewModifier: ViewModifier {
    let text: String
    
    func body(content: Content) -> some View {
        content
            .textSelection(.enabled)
    }
}

extension View {
    func copyable(_ text: String) -> some View {
        self.modifier(CopyableViewModifier(text: text))
    }
}

