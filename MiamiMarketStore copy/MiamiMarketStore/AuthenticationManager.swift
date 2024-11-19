import Foundation
import FirebaseAuth

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {}

    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authData = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authData.user)
    }

    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authData = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authData.user)
    }
}

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}
