import SwiftUI
import FirebaseAuth

@MainActor
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignedIn = false
    @State private var showError = false
    @State private var errorMessage = ""

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            showError = true
            return
        }

        Task {
            do {
                let _ = try await AuthenticationManager.shared.signIn(email: email, password: password)
                isSignedIn = true // Triggers navigation to the home page
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Email and password text fields
                TextField("email", text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8.0)

                SecureField("password", text: $password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8.0)
                    .padding(25)

                // Sign In Button
                Button(action: {
                    signIn()
                }) {
                    Text("Sign In")
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8.0)
                        .padding(.bottom)
                }
                .navigationDestination(isPresented: $isSignedIn) {
                    homePageLoggedIn(isSignedIn: $isSignedIn)
                        .navigationBarBackButtonHidden(true) // Prevent back navigation to LoginView
                }

                // Sign Up Link
                NavigationLink(destination: SignInPage()) {
                    Text("Don't have an account? Sign up")
                        .bold()
                        .foregroundColor(.blue)
                        .padding(.bottom, 25)
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Authentication Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


#Preview {
    LoginView()
}

