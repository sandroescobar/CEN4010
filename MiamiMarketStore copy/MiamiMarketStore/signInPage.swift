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
        NavigationStack{
            VStack {
                Spacer()
                
                // Email TextField
                TextField("email", text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8.0)
                
                // Password TextField
                SecureField("password", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8.0)
                    .padding(25)
                
                // Create Account Button
                Button(action: {
                    createAccount()
                }) {
                    Text("Create Account")
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8.0)
                        .foregroundColor(.blue)
                }
                .navigationDestination(isPresented: $isSignedIn) {                    homePageLoggedIn(isSignedIn: $isSignedIn)
                        
                }
                
                
                Spacer()
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    SignInPage()
}
