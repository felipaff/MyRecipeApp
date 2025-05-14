//
//  AuthService.swift
//  MyRecipeApp
//
//  Created by Felipe Peña on 24-04-25.
//

// Services/AuthService.swift
import FirebaseAuth

class AuthService {
    static let shared = AuthService()

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    func logout() throws {
        try FirebaseManager.shared.auth.signOut()
    }

    var currentUser: User? {
        return FirebaseManager.shared.auth.currentUser
    }
}
