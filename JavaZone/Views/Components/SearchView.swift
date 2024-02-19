// Search code based on https://stackoverflow.com/a/58473985/896214

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String

    private var showCancelButton: Bool {
        searchText != ""
    }

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("Search", text: $searchText).foregroundColor(.primary).autocapitalization(.none)

                Button(action: {
                    self.searchText = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                })
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)

            if showCancelButton {
                Button("Cancel") {
                        endEditing(true)
                        self.searchText = ""
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView(searchText: .constant("Test"))
        }
    }
}
