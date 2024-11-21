

import SwiftUI
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

struct LocationPage: View {
    @State private var isLocationSharing = false
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var locationStatus: String = "Not Determined"
    @State private var errorMessage: String?

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
                        Text(locationStatus)
                            .font(.headline)
                            .foregroundColor(statusColor)

                        if let location = currentLocation {
                            VStack(spacing: 5) {
                                Text("Current Location:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("Lat: \(location.latitude), Lon: \(location.longitude)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
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
                            requestLocationPermission()
                            startLocationSharing()
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
                            stopLocationSharing()
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

                    Spacer()

                    // Error Message
                    if let errorMessage = errorMessage {
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

    private func requestLocationPermission() {
        locationStatus = "Requesting Permission..."
    }

    private func startLocationSharing() {
        isLocationSharing = true
        locationStatus = "Sharing Location"
    }

    private func stopLocationSharing() {
        isLocationSharing = false
        locationStatus = "Location Sharing Stopped"
    }

    private var statusColor: Color {
        switch locationStatus {
        case "Sharing Location":
            return .green
        case "Location Sharing Stopped", "Requesting Permission...":
            return .yellow
        default:
            return .red
        }
    }
}

#Preview {
    LocationPage()
}
