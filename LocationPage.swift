import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var locationStatus: String = "Not Determined"
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update location every 10 meters
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationStatus = "Authorized"
        case .denied:
            locationStatus = "Denied"
            errorMessage = "Please enable location services in Settings"
        case .notDetermined:
            locationStatus = "Not Determined"
        case .restricted:
            locationStatus = "Restricted"
            errorMessage = "Location access is restricted"
        @unknown default:
            locationStatus = "Unknown"
        }
    }
}

struct LocationPage: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isLocationSharing = false
    
    // Function to save location to Firestore
    private func saveLocationToFirestore() {
        guard let location = locationManager.location,
              let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": FieldValue.serverTimestamp(),
            "userId": currentUser.uid
        ]
        
        db.collection("userLocations").document(currentUser.uid).setData(locationData) { error in
            if let error = error {
                locationManager.errorMessage = "Error saving location: \(error.localizedDescription)"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack {
                        Image(systemName: "location.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        
                        Text("Location Sharing")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 10) {
                        Text(locationManager.locationStatus)
                            .font(.headline)
                            .foregroundColor(statusColor)
                        
                        if let location = locationManager.location {
                            VStack(spacing: 5) {
                                Text("Current Location:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("Lat: \(location.coordinate.latitude, specifier: "%.4f")")
                                Text("Lon: \(location.coordinate.longitude, specifier: "%.4f")")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 5)
                    )
                    
                    Spacer()
                    
                    if !isLocationSharing {
                        Button(action: {
                            locationManager.requestPermission()
                            locationManager.startUpdating()
                            isLocationSharing = true
                            saveLocationToFirestore()
                        }) {
                            Text("Start Sharing Location")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    } else {
                        Button(action: {
                            locationManager.stopUpdating()
                            isLocationSharing = false
                        }) {
                            Text("Stop Sharing Location")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                    
                    NavigationLink(destination: Text("Home")) {
                        Text("Back to Home")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    if let errorMessage = locationManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .navigationTitle("Location")
        }
    }
    
    private var statusColor: Color {
        switch locationManager.locationStatus {
        case "Authorized":
            return .green
        case "Not Determined":
            return .yellow
        default:
            return .red
        }
    }
}

#Preview {
    LocationPage()
}
