//
//  LocationPage.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/12/24.
//  Edited Alejandro Alonso on 11/19/24

import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationViewModel: NSObject, ObservableObject {
    @Published var isLocationSharing = false
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationStatus: String = "Not Determined"
    @Published var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationSharing() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Location services are disabled"
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationSharing = true
        locationStatus = "Sharing Location"
    }
    
    func stopLocationSharing() {
        locationManager.stopUpdatingLocation()
        isLocationSharing = false
        locationStatus = "Location Sharing Stopped"
        
        // Optional: Remove location from Firebase when stopping
        removeLocationFromFirebase()
    }
    
    private func saveLocationToFirebase(_ location: CLLocationCoordinate2D) {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "User not authenticated"
            return
        }
        
        let locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("user_locations").document(currentUser.uid).setData(locationData) { error in
            if let error = error {
                self.errorMessage = "Failed to save location: \(error.localizedDescription)"
            }
        }
    }
    
    private func removeLocationFromFirebase() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "User not authenticated"
            return
        }
        
        db.collection("user_locations").document(currentUser.uid).delete { error in
            if let error = error {
                self.errorMessage = "Failed to remove location: \(error.localizedDescription)"
            }
        }
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location.coordinate
        saveLocationToFirebase(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location manager error: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = "Location Access Granted"
        case .denied, .restricted:
            locationStatus = "Location Access Denied"
            errorMessage = "Please enable location permissions in Settings"
        case .notDetermined:
            locationStatus = "Location Permission Not Determined"
        @unknown default:
            locationStatus = "Unknown Authorization Status"
        }
    }
}

struct LocationPage: View {
    @StateObject private var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Location Sharing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(viewModel.locationStatus)
                    .foregroundColor(statusColor)
                
                if let location = viewModel.currentLocation {
                    Text("Current Location:")
                    Text("Lat: \(location.latitude), Lon: \(location.longitude)")
                        .font(.caption)
                }
                
                if !viewModel.isLocationSharing {
                    Button(action: {
                        viewModel.requestLocationPermission()
                        viewModel.startLocationSharing()
                    }) {
                        Text("Start Sharing Location")
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        viewModel.stopLocationSharing()
                    }) {
                        Text("Stop Sharing Location")
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
            .navigationTitle("Location")
        }
    }
    
    private var statusColor: Color {
        switch viewModel.locationStatus {
        case "Location Access Granted":
            return .green
        case "Location Access Denied", "Failed to Get Location":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    LocationPage()
}
