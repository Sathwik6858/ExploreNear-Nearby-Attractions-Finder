//
//  SearchBar.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var hasCancel: Bool = true
    var action: ()->()
    var onCancel: ()->()
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 40)
                    .cornerRadius(12)
                    .foregroundColor(.red)
                HStack {
                    Spacer()
                    Image("search")
                    TextField("Search", text: $searchText, onEditingChanged: { editing in
                        action()
                    })
                    .font(.headline)
                    .frame(height: 50)
                    .textFieldStyle(.plain)
                    .cornerRadius(12)
                }
                .background(.white)
                .cornerRadius(12)
            }
            if hasCancel {
                Button(action: {
                    searchText = ""
                    onCancel()
                }) {
                    Text("Cancel")
                        .foregroundColor(Color.black)
                        .font(.headline)
                }
                .padding(.trailing, 8)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut(duration: 1.0), value: UUID())
            }
        }
    }
}
