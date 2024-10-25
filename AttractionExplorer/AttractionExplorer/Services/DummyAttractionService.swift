//
//  DummyAttractionService.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import Foundation

class DummyAttractionService {
    
    static func getDummyAttractions() -> [Attraction] {
        return [
            Attraction(attractionID: 1, name: "Big Ben", lat: 51.5007, long: -0.1246, zipcode: "SW1A 0AA", description: "Famous clock tower and iconic symbol of London."),
            Attraction(attractionID: 2, name: "London Eye", lat: 51.5033, long: -0.1195, zipcode: "SE1 7PB", description: "Giant Ferris wheel on the South Bank of the River Thames."),
            Attraction(attractionID: 3, name: "Tower of London", lat: 51.5081, long: -0.0759, zipcode: "EC3N 4AB", description: "Historic castle and former prison on the River Thames."),
            Attraction(attractionID: 4, name: "British Museum", lat: 51.5194, long: -0.1270, zipcode: "WC1B 3DG", description: "World-renowned museum of history and culture."),
            Attraction(attractionID: 5, name: "Buckingham Palace", lat: 51.5014, long: -0.1419, zipcode: "SW1A 1AA", description: "London residence and administrative headquarters of the monarch."),
            Attraction(attractionID: 6, name: "Trafalgar Square", lat: 51.5080, long: -0.1281, zipcode: "WC2N 5DN", description: "Public square in the City of Westminster, known for Nelson's Column."),
            Attraction(attractionID: 7, name: "Westminster Abbey", lat: 51.4993, long: -0.1273, zipcode: "SW1P 3PA", description: "Gothic abbey church and site of royal coronations."),
            Attraction(attractionID: 8, name: "St. Paul's Cathedral", lat: 51.5138, long: -0.0984, zipcode: "EC4M 8AD", description: "Famous domed cathedral and iconic feature of London's skyline."),
            Attraction(attractionID: 9, name: "Hyde Park", lat: 51.5074, long: -0.1657, zipcode: "W2 2UH", description: "One of London's largest parks, famous for Speaker's Corner."),
            Attraction(attractionID: 10, name: "The Shard", lat: 51.5045, long: -0.0865, zipcode: "SE1 9SG", description: "A 95-story skyscraper offering panoramic views of London."),
        ]
    }
}
