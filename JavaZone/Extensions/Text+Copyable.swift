import SwiftUI

struct CopyableViewModifier: ViewModifier {
    let text: String

    func body(content: Content) -> some View {
        content
            .contextMenu(ContextMenu(menuItems: {
              Button("Copy", action: {
                UIPasteboard.general.string = text
              })
            }))
    }
}

extension View {
    func copyable(_ text: String) -> some View {
        self.modifier(CopyableViewModifier(text: text))
    }
}

