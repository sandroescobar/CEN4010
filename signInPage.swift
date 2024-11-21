//
//  signInPage.swift
//  HelloWorld
//
//  Created by Nathalia Carrasquero on 11/20/24.
//

import SwiftUI
import FirebaseAuth

struct SignInPage: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSignedIn = false
    @State private var isAccountCreated = false // State to handle navigation back to LoginView after account creation

    // Function to create a new account
    func createAccount() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            showError = true
            return
        }

        Task {
            do {
                // Attempt to create a user with Firebase Authentication
                let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
                isAccountCreated = true // Navigate back to LoginView after successful account creation
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    // Welcome text
                    Text("Create an Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 30)

                    // Email TextField
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

                    // Password TextField
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

                    // Create Account Button
                    Button(action: {
                        createAccount()
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.blue.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding(.bottom, 10)

                    // Sign In Link
                    NavigationLink(destination: LoginViewupdated()) {
                        Text("Already have an account? Sign in")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }

                    Spacer()
                }
                .alert(isPresented: $showError) {
                    Alert(
                        title: Text("Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

#Preview {
    SignInPage()
}
