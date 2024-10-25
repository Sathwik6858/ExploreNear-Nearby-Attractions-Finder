//
//  AttractionPinView.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import Foundation
import SwiftUI

struct AttractionPinView: View {
    var attraction: Attraction
    
    var body: some View {
        VStack {
            Image(systemName: pinImage(for: attraction.attractionID))
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(pinColor(for: attraction.attractionID))
            
            Text(attraction.name)
                .font(.caption)
                .foregroundColor(.black)
                .padding(5)
                .background(Color.white)
                .cornerRadius(5)
        }
    }
    

    func pinColor(for id: Int) -> Color {
        switch id % 3 {
        case 0: return .red
        case 1: return .blue
        case 2: return .green
        default: return .gray
        }
    }
    

    func pinImage(for id: Int) -> String {
        switch id % 3 {
        case 0: return "star.fill"
        case 1: return "mappin.circle.fill"
        case 2: return "flag.fill"
        default: return "mappin"
        }
    }
}
