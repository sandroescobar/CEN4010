import SwiftUI
import FirebaseAuth

@MainActor
struct LoginViewupdated: View {
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
                isSignedIn = true
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Logo Section
                    Image("99B8D0F9-934C-4635-8E9C-90E6A2ACB67E") // Replace with your asset name for the uploaded logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 30)

                    // Welcome Title
                    Text("Welcome to Activity Finder")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 30)

                    // Email Input
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

                    // Password Input
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

                    // Sign In Button
                    Button(action: {
                        signIn()
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.blue.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding(.top, 10)
                    .navigationDestination(isPresented: $isSignedIn) {
                        homePageLoggedIn(isSignedIn: $isSignedIn)
                            .navigationBarBackButtonHidden(true)
                    }

                    // Sign Up Link
                    NavigationLink(destination: SignInPage()) {
                        Text("Don't have an account? Sign up")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }

                    Spacer()
                }
                .alert(isPresented: $showError) {
                    Alert(
                        title: Text("Authentication Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginViewupdated()
    }
}
