
import SwiftUI
import FirebaseAuth

struct SettingPage: View {
    @Binding var isSignedIn: Bool // Add back the binding for signed-in state
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

            // Log the user out
            isSignedIn = false // Update the binding to log out
            print("Account deleted successfully")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

#Preview {
    SettingPage(isSignedIn: .constant(true)) // Provide a mock binding value
}
