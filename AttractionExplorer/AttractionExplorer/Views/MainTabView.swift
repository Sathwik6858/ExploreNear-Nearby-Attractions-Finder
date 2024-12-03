//
//  MainTabView.swift
//  AttractionExplorer
//
//  Created by Sathwik Alasyam on 12/1/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var searchText: String = "" // State to hold search text for AttractionMapView

    var body: some View {
        ZStack {
            Color.white // White background for TabView
                .edgesIgnoringSafeArea(.all)

            TabView {
                // Map View Tab
                AttractionMapView(searchText: $searchText)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                // Favorites View Tab
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "star.fill")
                    }
            }
        }
    }
}

#Preview {
    MainTabView()
}
