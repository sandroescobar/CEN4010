//
//  PreferencePage.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/12/24.
// Edited by Alejandro Alonso on 11/19/24
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

// Enum to categorize activities
enum ActivityCategory: String, CaseIterable, Identifiable {
    case outdoors = "Outdoors"
    case sports = "Sports"
    case entertainment = "Entertainment"
    case wellness = "Wellness"
    case learning = "Learning"
    case social = "Social"
    case foodAndDrink = "Food & Drink"
    
    var id: String { self.rawValue }
}

// Struct to represent an activity with more details
struct ActivityOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: ActivityCategory
    let icon: String
}

// UserPreferences model for local storage and Firebase
struct UserPreferencesModel: Codable {
    var activities: [String]
    var timestamp: Date
}

class PreferencesViewModel: ObservableObject {
    @Published var selectedActivities: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "userActivityPreferences"
    
    // Comprehensive list of activities by category
    let activitiesByCategory: [ActivityCategory: [ActivityOption]] = [
        .outdoors: [
            ActivityOption(name: "Hiking", category: .outdoors, icon: "mountain.2"),
            ActivityOption(name: "Camping", category: .outdoors, icon: "tent"),
            ActivityOption(name: "Rock Climbing", category: .outdoors, icon: "flag"),
            ActivityOption(name: "Kayaking", category: .outdoors, icon: "water.waves"),
            ActivityOption(name: "Cycling", category: .outdoors, icon: "bicycle")
        ],
        .sports: [
            ActivityOption(name: "Basketball", category: .sports, icon: "basketball"),
            ActivityOption(name: "Soccer", category: .sports, icon: "football"),
            ActivityOption(name: "Tennis", category: .sports, icon: "tennisball"),
            ActivityOption(name: "Swimming", category: .sports, icon: "water.waves"),
            ActivityOption(name: "Volleyball", category: .sports, icon: "volleyball")
        ],
        .entertainment: [
            ActivityOption(name: "Movies", category: .entertainment, icon: "film"),
            ActivityOption(name: "Live Music", category: .entertainment, icon: "music.mic"),
            ActivityOption(name: "Comedy Shows", category: .entertainment, icon: "face.smiling"),
            ActivityOption(name: "Theater", category: .entertainment, icon: "theatermasks"),
            ActivityOption(name: "Art Exhibitions", category: .entertainment, icon: "paintbrush")
        ],
        .wellness: [
            ActivityOption(name: "Yoga", category: .wellness, icon: "figure.yoga"),
            ActivityOption(name: "Meditation", category: .wellness, icon: "moon"),
            ActivityOption(name: "Pilates", category: .wellness, icon: "figure.strengthtraining.traditional"),
            ActivityOption(name: "Running", category: .wellness, icon: "figure.run"),
            ActivityOption(name: "Dance Fitness", category: .wellness, icon: "figure.dance")
        ],
        .learning: [
            ActivityOption(name: "Workshops", category: .learning, icon: "book"),
            ActivityOption(name: "Language Classes", category: .learning, icon: "globe"),
            ActivityOption(name: "Tech Meetups", category: .learning, icon: "desktopcomputer"),
            ActivityOption(name: "Photography Class", category: .learning, icon: "camera"),
            ActivityOption(name: "Cooking Class", category: .learning, icon: "fork.knife")
        ],
        .social: [
            ActivityOption(name: "Board Game Night", category: .social, icon: "dice"),
            ActivityOption(name: "Networking Events", category: .social, icon: "person.2"),
            ActivityOption(name: "Group Fitness", category: .social, icon: "person.3"),
            ActivityOption(name: "Club Meetups", category: .social, icon: "person.circle"),
            ActivityOption(name: "Community Service", category: .social, icon: "heart")
        ],
        .foodAndDrink: [
            ActivityOption(name: "Food Festivals", category: .foodAndDrink, icon: "fork.knife"),
            ActivityOption(name: "Wine Tasting", category: .foodAndDrink, icon: "wineglass"),
            ActivityOption(name: "Cooking Workshops", category: .foodAndDrink, icon: "pot.fill"),
            ActivityOption(name: "Restaurant Tours", category: .foodAndDrink, icon: "map"),
            ActivityOption(name: "Coffee Meetups", category: .foodAndDrink, icon: "cup.and.saucer")
        ]
    ]
    
    init() {
        loadSavedPreferences()
    }
    
    // Local caching methods
    func savePreferencesToLocal() {
        do {
            let preferences = UserPreferencesModel(
                activities: Array(selectedActivities),
                timestamp: Date()
            )
            let encodedData = try JSONEncoder().encode(preferences)
            userDefaults.set(encodedData, forKey: preferencesKey)
        } catch {
            print("Error saving preferences locally: \(error)")
        }
    }
    
    func loadSavedPreferences() {
        guard let data = userDefaults.data(forKey: preferencesKey) else { return }
        do {
            let preferences = try JSONDecoder().decode(UserPreferencesModel.self, from: data)
            selectedActivities = Set(preferences.activities)
        } catch {
            print("Error loading preferences: \(error)")
        }
    }
    
    // Firebase save method
    func savePreferencesToFirebase(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let userPreferencesRef = db.collection("user_preferences").document(currentUser.uid)
        
        let preferencesData: [String: Any] = [
            "activities": Array(selectedActivities),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        userPreferencesRef.setData(preferencesData) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            // Save to local storage after successful Firebase save
            self?.savePreferencesToLocal()
            completion(true)
        }
    }
    
    // Toggle activity selection with 7-activity limit
    func toggleActivity(_ activity: String) -> Bool {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
            return true
        }
        
        if selectedActivities.count >= 7 {
            return false
        }
        
        selectedActivities.insert(activity)
        return true
    }
}

struct PreferencePage: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @State private var showMaxSelectionAlert = false
    @State private var saveSuccessful = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Your Interests")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Choose up to 7 activities (Current: \(viewModel.selectedActivities.count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TabView {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        CategoryActivityView(
                            category: category, 
                            activities: viewModel.activitiesByCategory[category] ?? [],
                            selectedActivities: viewModel.selectedActivities
                        ) { activity in
                            if !viewModel.toggleActivity(activity) {
                                showMaxSelectionAlert = true
                            }
                        }
                        .tag(category)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundColor: .clear))
                .frame(height: 400)
                
                Button(action: savePreferences) {
                    Text(viewModel.isLoading ? "Saving..." : "Save Preferences")
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.selectedActivities.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(viewModel.selectedActivities.isEmpty || viewModel.isLoading)
            }
            .navigationTitle("Your Preferences")
            .alert("Maximum Selections", isPresented: $showMaxSelectionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You can only select up to 7 activities.")
            }
            .alert("Preferences Saved", isPresented: $saveSuccessful) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your activity preferences have been saved successfully!")
            }
        }
    }
    
    private func savePreferences() {
        viewModel.savePreferencesToFirebase { success in
            if success {
                saveSuccessful = true
            }
        }
    }
}

struct CategoryActivityView: View {
    let category: ActivityCategory
    let activities: [ActivityOption]
    let selectedActivities: Set<String>
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack {
            Text(category.rawValue)
                .font(.headline)
                .padding()
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(activities, id: \.id) { activity in
                        Button(action: { onSelect(activity.name) }) {
                            VStack {
                                Image(systemName: activity.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(selectedActivities.contains(activity.name) ? .white : .blue)
                                
                                Text(activity.name)
                                    .font(.caption)
                                    .foregroundColor(selectedActivities.contains(activity.name) ? .white : .primary)
                            }
                            .padding()
                            .background(selectedActivities.contains(activity.name) ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    PreferencePage()
}
