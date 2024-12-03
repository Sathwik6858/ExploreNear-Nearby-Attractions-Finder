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
    @EnvironmentObject var sessionManager: UserSessionManager
    @StateObject private var locationManager = LocationManager()
    @Binding var searchText: String // Binding for search text
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var attractions = DummyAttractionService.getDummyAttractions()
    @State private var selectedAttraction: Attraction? // Store selected attraction for adding to favorites
    @State private var showFavoriteAlert = false

    var body: some View {
        ZStack {
            // Map with annotations
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: attractions) { attraction in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: attraction.lat, longitude: attraction.long)) {
                    AttractionPinView(attraction: attraction)
                        .onTapGesture {
                            selectedAttraction = attraction
                        }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                // Center map on user location if available
                if let userLocation = locationManager.location {
                    region.center = userLocation.coordinate
                }
            }

            VStack {
                // Search Bar at the top
                SearchBar(
                    searchText: $searchText,
                    onSearch: {
                        fetchAttractionsByZip(zipCode: searchText)
                    },
                    onCancel: {
                        searchText = ""
                        resetToDefaultAttractions()
                    }
                )
                .padding()
                .background(Color.white.opacity(0.9)) // Ensure visibility over map
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal, 16)
                .padding(.top, 50) // Adjust for status bar or notch
                
                Spacer()

                // Add-to-Favorites Button
                if let selectedAttraction = selectedAttraction {
                    Button(action: {
                        addAttractionToFavorites(attraction: selectedAttraction)
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                            Text("Add to Favorites")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding()
                }

                // Zoom Controls
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: zoomIn) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        
                        Button(action: zoomOut) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showFavoriteAlert) {
            Alert(
                title: Text("Added to Favorites"),
                message: Text("The attraction was successfully added to your favorites."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // Fetch attractions by ZIP code
    private func fetchAttractionsByZip(zipCode: String) {
        guard !zipCode.isEmpty else {
            alertMessage = "Please enter a valid ZIP code."
            showAlert = true
            return
        }

        let connection = PostgresConnection()
        let newAttractions = connection.getAttractionsByZip(zipCode: zipCode)
        
        if newAttractions.isEmpty {
            alertMessage = "No attractions found for ZIP code \(zipCode)."
            showAlert = true
        } else {
            self.attractions = newAttractions
            if let firstAttraction = newAttractions.first {
                region.center = CLLocationCoordinate2D(latitude: firstAttraction.lat, longitude: firstAttraction.long)
            }
        }
    }

    // Reset to default attractions
    private func resetToDefaultAttractions() {
        self.attractions = DummyAttractionService.getDummyAttractions()
        if let userLocation = locationManager.location {
            region.center = userLocation.coordinate
        } else {
            region.center = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275) // Default to London
        }
    }

    // Add attraction to favorites
    private func addAttractionToFavorites(attraction: Attraction) {
        guard !sessionManager.currentUserName.isEmpty else {
            alertMessage = "Error: No user logged in."
            showAlert = true
            return
        }

        let connection = PostgresConnection()
        let success = connection.addAttractionToFavorites(userString: sessionManager.currentUserName, attractionID: attraction.attractionID)

        if success {
            selectedAttraction = nil // Clear the selection
            showFavoriteAlert = true
        } else {
            alertMessage = "Error adding attraction to favorites."
            showAlert = true
        }
    }

    // Zoom in
    private func zoomIn() {
        let zoomFactor = 0.5 // Decrease span for closer zoom
        region.span.latitudeDelta = max(region.span.latitudeDelta * zoomFactor, 0.01)
        region.span.longitudeDelta = max(region.span.longitudeDelta * zoomFactor, 0.01)
    }

    // Zoom out
    private func zoomOut() {
        let zoomFactor = 2.0 // Increase span for farther zoom
        region.span.latitudeDelta = min(region.span.latitudeDelta * zoomFactor, 10.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * zoomFactor, 10.0)
    }
}

// Location Manager
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

// Preview for AttractionMapView
struct AttractionMapView_Previews: PreviewProvider {
    static var previews: some View {
        AttractionMapView(searchText: .constant(""))
            .environmentObject(UserSessionManager())
    }
}
