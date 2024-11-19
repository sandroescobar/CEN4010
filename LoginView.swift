import SwiftUI
import FirebaseAuth

@MainActor
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignedIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            showError = true
            return
        }
        
        // Basic email validation
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let _ = try await AuthenticationManager.shared.signIn(email: email, password: password)
                isSignedIn = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // App Logo or Title could go here
                Spacer()
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal)
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8.0)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8.0)
                }
                
                // Sign In Button
                Button(action: signIn) {
                    ZStack {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
                            .cornerRadius(8.0)
                            .opacity(isLoading ? 0 : 1)
                        
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                }
                .disabled(isLoading)
                
                NavigationLink(destination: SignInPage()) {
                    Text("Don't have an account? Sign up")
                        .bold()
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $isSignedIn) {
                homePageLoggedIn()
                    .navigationBarBackButtonHidden(true)
            }
            .alert("Authentication Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    LoginView()
}
