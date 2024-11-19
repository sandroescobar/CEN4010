//
//  SettingPage.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/12/24.
// Edited by Alejandro Alonso on 11/19/24

import SwiftUI
import FirebaseAuth

struct SettingPage: View {
    @State private var userEmail: String = ""
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Email Display
                HStack {
                    Text("Email:")
                        .font(.headline)
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Delete Account Button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("Delete Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Spacer()
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                fetchUserEmail()
            }
        }
    }
    
    private func fetchUserEmail() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? "No email"
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            showError(message: "No user found")
            return
        }
        
        user.delete { error in
            if let error = error {
                showError(message: error.localizedDescription)
                return
            }
            
            // Navigate to welcome screen
            // Note: In SwiftUI, navigation is typically handled differently
            // You might use @AppStorage or a custom NavigationLink
            print("Account deleted successfully")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

#Preview {
    SettingPage()
}
