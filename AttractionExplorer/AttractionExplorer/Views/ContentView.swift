//
//  ContentView.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import SwiftUI

struct ContentView: View {
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            ZStack{
                AttractionMapView()
                    .ignoresSafeArea()
                VStack{
                    SearchBar(searchText: $searchText, hasCancel: false, action: {print("Search Clicked")}, onCancel: {print("Search cancelled")})                        .padding()
                    Spacer()
                }.padding()
                

            }
        }
        
    }
}

#Preview {
    ContentView()
}
