import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

// Struct to represent an activity with location
struct LocationBasedActivity: Identifiable, Codable {
    let id: String
    let name: String
    let category: ActivityCategory
    let latitude: Double
    let longitude: Double
    let address: String
    let distance: Double? = nil
}

class ActivityRecommendationViewModel: ObservableObject {
    @Published var nearbyActivities: [LocationBasedActivity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let maxRecommendationRadius: CLLocationDistance = 10 // kilometers
    
    func findNearbyActivities(currentLocation: CLLocationCoordinate2D) {
        isLoading = true
        nearbyActivities.removeAll()
        
        // First, query Firebase for activities near the user's location
        db.collection("activities")
            .whereField("latitude", isGreaterThanOrEqualTo: currentLocation.latitude - radiusDegrees())
            .whereField("latitude", isLessThanOrEqualTo: currentLocation.latitude + radiusDegrees())
            .whereField("longitude", isGreaterThanOrEqualTo: currentLocation.longitude - radiusDegrees())
            .whereField("longitude", isLessThanOrEqualTo: currentLocation.longitude + radiusDegrees())
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to fetch activities: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                let activities = querySnapshot?.documents.compactMap { document -> LocationBasedActivity? in
                    let data = document.data()
                    guard 
                        let name = data["name"] as? String,
                        let categoryRawValue = data["category"] as? String,
                        let category = ActivityCategory(rawValue: categoryRawValue),
                        let latitude = data["latitude"] as? Double,
                        let longitude = data["longitude"] as? Double,
                        let address = data["address"] as? String
                    else { return nil }
                    
                    return LocationBasedActivity(
                        id: document.documentID,
                        name: name,
                        category: category,
                        latitude: latitude,
                        longitude: longitude,
                        address: address
                    )
                }
                
                // Filter activities by actual distance
                self.nearbyActivities = activities.filter { activity in
                    let activityLocation = CLLocation(
                        latitude: activity.latitude, 
                        longitude: activity.longitude
                    )
                    let userLocation = CLLocation(
                        latitude: currentLocation.latitude, 
                        longitude: currentLocation.longitude
                    )
                    
                    let distanceInKm = activityLocation.distance(from: userLocation) / 1000
                    return distanceInKm <= self.maxRecommendationRadius
                }
                
                self.isLoading = false
            }
    }
    
    // Calculate radius in degrees (approximate)
    private func radiusDegrees() -> Double {
        // 1 degree is approximately 111 km
        return maxRecommendationRadius / 111.0
    }
    
    // Recommendation algorithm
    func recommendActivities(userPreferences: Set<String>) -> [LocationBasedActivity] {
        // Filter nearby activities based on user preferences
        return nearbyActivities.filter { activity in
            // Match activity category with user preferences
            userPreferences.contains(activity.category.rawValue)
        }
    }
}

struct ActivityRecommendationPage: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var recommendationViewModel = ActivityRecommendationViewModel()
    @StateObject private var preferencesViewModel = PreferencesViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if locationViewModel.isLocationSharing {
                    Text("Nearby Recommended Activities")
                        .font(.headline)
                    
                    if recommendationViewModel.isLoading {
                        ProgressView()
                    } else if let error = recommendationViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    } else if recommendationViewModel.nearbyActivities.isEmpty {
                        Text("No nearby activities found")
                    } else {
                        List(recommendedActivities) { activity in
                            VStack(alignment: .leading) {
                                Text(activity.name)
                                    .font(.headline)
                                Text(activity.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(activity.address)
                                    .font(.caption)
                            }
                        }
                    }
                } else {
                    Text("Start sharing location to get recommendations")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Recommendations")
            .onAppear {
                // Trigger recommendations when location is available
                if let location = locationViewModel.currentLocation {
                    recommendationViewModel.findNearbyActivities(currentLocation: location)
                }
            }
            .onChange(of: locationViewModel.currentLocation) { newLocation in
                guard let location = newLocation else { return }
                recommendationViewModel.findNearbyActivities(currentLocation: location)
            }
        }
    }
    
    // Computed property for recommended activities
    private var recommendedActivities: [LocationBasedActivity] {
        recommendationViewModel.recommendActivities(
            userPreferences: preferencesViewModel.selectedActivities
        )
    }
}

#Preview {
    ActivityRecommendationPage()
}
