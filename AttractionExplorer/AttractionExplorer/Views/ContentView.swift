//
//  ContentView.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = "" // State to hold search text

    var body: some View {
        VStack {
            ZStack {
                // Map View with search logic integration
                AttractionMapView(searchText: $searchText)
                    .ignoresSafeArea()
                
                // Overlay with Search Bar
                VStack {
                    SearchBar(
                        searchText: $searchText,
                        onSearch: {
                            print("Search clicked with text: \(searchText)")
                            // Validate and execute the search logic
                            if !searchText.isEmpty {
                                NotificationCenter.default.post(name: .searchByZipCode, object: searchText)
                            } else {
                                print("Search text is empty.")
                            }
                        },
                        onCancel: {
                            print("Search cancelled")
                            searchText = "" // Clear the search text
                            //NotificationCenter.default.post(name: .resetSearch, object: nil)
                        }
                    )
                    .padding() // Add padding for spacing
                    Spacer() // Push everything above to the top
                }
            }
        }
    }
}

// Notification names to communicate search actions to the AttractionMapView
extension Notification.Name {
    static let searchByZipCode = Notification.Name("searchByZipCode")
    static let resetSearch = Notification.Name("resetSearch")
}

#Preview {
    ContentView()
}
