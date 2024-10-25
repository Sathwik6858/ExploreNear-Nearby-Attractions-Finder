//
//  AttractionMapView.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 10/24/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct AttractionMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    private let attractions = DummyAttractionService.getDummyAttractions()

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: attractions) { attraction in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(attraction.lat), longitude: Double(attraction.long))) {
                AttractionPinView(attraction: attraction)
            }
        }
        .onAppear {
            if let userLocation = locationManager.location {
                region.center = userLocation.coordinate
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var location: CLLocation? = nil

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.location = location
            }
        }
    }
}

