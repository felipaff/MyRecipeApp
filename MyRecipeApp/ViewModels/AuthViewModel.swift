//
//  AuthViewModel.swift
//  MyRecipeApp
//
//  Created by Felipe Peña on 24-04-25.
//

// ViewModels/AuthViewModel.swift
import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let _ = result {
                DispatchQueue.main.async {
                    self?.isLoggedIn = true
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch {
            print("Error signing out")
        }
    }
}

// 👇 Agrega esto al final
extension AuthViewModel {
    var displayName: String? {
        Auth.auth().currentUser?.displayName
    }

    var photoURL: String? {
        Auth.auth().currentUser?.photoURL?.absoluteString
    }
}
