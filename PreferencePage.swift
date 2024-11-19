//
//  PreferencePage.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/12/24.
// Edited by Alejandro Alonso on 11/19/24
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PreferencePage: View {
    // Activity type options
    let activityTypes = [
        "Sports", 
        "Outdoor Adventures", 
        "Cultural Events", 
        "Music Concerts", 
        "Food & Dining", 
        "Art Exhibitions", 
        "Fitness Classes", 
        "Tech Meetups", 
        "Dancing", 
        "Workshops", 
        "Cinema", 
        "Hiking", 
        "Photography", 
        "Gaming", 
        "Yoga"
    ]
    
    // State variables
    @State private var selectedActivities: Set<String> = []
    @State private var showMaxSelectionAlert = false
    @State private var isSaving = false
    @State private var saveSuccessful = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Your Interests")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Choose up to 7 activities you enjoy")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(activityTypes, id: \.self) { activity in
                            ActivityChip(
                                title: activity, 
                                isSelected: selectedActivities.contains(activity)
                            ) {
                                // Selection logic
                                if selectedActivities.contains(activity) {
                                    selectedActivities.remove(activity)
                                } else {
                                    if selectedActivities.count >= 5 {
                                        showMaxSelectionAlert = true
                                    } else {
                                        selectedActivities.insert(activity)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Button(action: savePreferences) {
                    Text(isSaving ? "Saving..." : "Save Preferences")
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(selectedActivities.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(selectedActivities.isEmpty || isSaving)
            }
            .navigationTitle("Your Preferences")
            .alert("Maximum Selections", isPresented: $showMaxSelectionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You can only select up to 5 activities.")
            }
            .alert("Preferences Saved", isPresented: $saveSuccessful) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your activity preferences have been saved successfully!")
            }
        }
    }
    
    private func savePreferences() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
        isSaving = true
        
        let db = Firestore.firestore()
        let userPreferencesRef = db.collection("user_preferences").document(currentUser.uid)
        
        let preferencesData: [String: Any] = [
            "activities": Array(selectedActivities),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        userPreferencesRef.setData(preferencesData) { error in
            isSaving = false
            
            if let error = error {
                print("Error saving preferences: \(error.localizedDescription)")
                return
            }
            
            saveSuccessful = true
        }
    }
}

// Custom Activity Chip View
struct ActivityChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding()
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    PreferencePage()
}
