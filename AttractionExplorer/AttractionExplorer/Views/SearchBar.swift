//
//  SearchBar.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var onSearch: () -> Void
    var onCancel: () -> Void

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by ZIP code", text: $searchText, onEditingChanged: { editing in
                    if !editing {
                        onSearch()
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)

            if !searchText.isEmpty {
                Button("Cancel") {
                    searchText = ""
                    onCancel()
                }
                .foregroundColor(.blue)
                .padding(.trailing, 8)
            }
        }
    }
}
