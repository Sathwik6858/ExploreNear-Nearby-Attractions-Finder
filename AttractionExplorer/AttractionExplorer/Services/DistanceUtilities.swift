//
//  DistanceUtilities.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 11/28/24.
//

import Foundation


func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let R = 6371.0 // Radius of the Earth in kilometers
    let lat1Rad = lat1 * .pi / 180.0
    let lon1Rad = lon1 * .pi / 180.0
    let lat2Rad = lat2 * .pi / 180.0
    let lon2Rad = lon2 * .pi / 180.0

    let dLat = lat2Rad - lat1Rad
    let dLon = lon2Rad - lon1Rad

    let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    let distance = R * c  // Distance in kilometers
    return distance
}
