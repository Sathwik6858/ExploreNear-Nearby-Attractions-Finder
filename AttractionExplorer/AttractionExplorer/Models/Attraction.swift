//
//  Attraction.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import Foundation

struct Attraction{
    var attractionID: Int 
    var name: String
    var lat: Double
    var long: Double
    var zipcode: String
    var address: String
    var description: String
}

extension Attraction: Identifiable{
    var id: Int { attractionID }
}
