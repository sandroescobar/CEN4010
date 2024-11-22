import SwiftUI
import FirebaseAuth

struct SettingPage: View {
    @Binding var isSignedIn: Bool
    @State private var userEmail: String = ""
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String? = nil
    @State private var isDarkMode = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: isDarkMode ? [Color.black, Color.gray] : [Color.blue.opacity(0.8), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack {
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                    .padding(.top, 30)

                    cardView(title: "Email:", content: userEmail)
                    cardView(title: "Password:", content: "••••••••")

                    HStack {
                        Text("Theme:")
                            .font(.headline)
                            .foregroundColor(isDarkMode ? .white : .primary)
                        Spacer()
                        Toggle(isOn: $isDarkMode) {
                            Text(isDarkMode ? "Dark" : "Light")
                                .font(.subheadline)
                                .foregroundColor(isDarkMode ? .gray : .secondary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isDarkMode ? Color.gray.opacity(0.2) : Color.white.opacity(0.9))
                            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
                    )
                    .padding(.horizontal)

                    buttonView(title: "Sign Out", backgroundColor: .blue, action: signOut)
                    buttonView(title: "Switch Account", backgroundColor: .gray, action: switchAccount)
                    buttonView(title: "Delete Account", backgroundColor: .red) {
                        showDeleteConfirmation = true
                    }
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

                    // Non-functioning Back to Home Button
                    buttonView(title: "Back to Home", backgroundColor: .blue) {
                        // Placeholder action for non-functional button
                    }

                    Spacer()

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 10)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                fetchUserEmail()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
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
            isSignedIn = false
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch {
            showError(message: "Error signing out: \(error.localizedDescription)")
        }
    }

    private func switchAccount() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
        } catch {
            showError(message: "Error switching account: \(error.localizedDescription)")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }

    private func cardView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .primary)
            Text(content)
                .font(.subheadline)
                .foregroundColor(isDarkMode ? .gray : .secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isDarkMode ? Color.gray.opacity(0.2) : Color.white.opacity(0.9))
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 3)
        )
        .padding(.horizontal)
    }

    private func buttonView(title: String, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

#Preview {
    SettingPage(isSignedIn: .constant(true)) // Provide a mock binding value
}
