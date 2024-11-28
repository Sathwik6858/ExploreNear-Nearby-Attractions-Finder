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
    @State var showAlert = false
    @State private var attractions = DummyAttractionService.getDummyAttractions()

    var body: some View {
        ZStack{
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
            VStack(){
                Spacer()
                Button("Get Attractions by zipcode + update map") {
                    let connection = PostgresConnection()
                    let newAttractions = connection.getAttractionsByZip(zipCode: "85281")
                    if newAttractions.isEmpty {
                        showAlert = true
                    } else {
                        self.attractions = newAttractions
                        if let firstAttraction = newAttractions.first {
                            region.center = CLLocationCoordinate2D(latitude: Double(firstAttraction.lat), longitude: Double(firstAttraction.long))
                        }
                    }
                }
                
                //this function does not work correctly at the moment, still debugging
                Button("Get Attractions by longitude and latitude + update map") {
                    let connection = PostgresConnection()
                    let newAttractions = connection.getAttractionsByCoordinates(lat: 33.4230, long: -111.9278, radius: 100.0)
                    if newAttractions.isEmpty {
                        showAlert = true
                    } else {
                        self.attractions = newAttractions
                        if let firstAttraction = newAttractions.first {
                            region.center = CLLocationCoordinate2D(latitude: Double(firstAttraction.lat), longitude: Double(firstAttraction.long))
                        }
                    }
                }
                
                Button("Add attraction to favorites via ID") {
                    let connection = PostgresConnection()
                    print(connection.addAttractionToFavorites(userString: "benash", attractionID: 1))
                }
                
                Button("Remove attraction from favorites via ID") {
                    let connection = PostgresConnection()
                    print(connection.removeAttractionFromFavorites(userString: "benash", attractionID: 1))
                }
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("No Attractions Found"), message: Text("Please check the zip code or coordinates."), dismissButton: .default(Text("OK")))
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

