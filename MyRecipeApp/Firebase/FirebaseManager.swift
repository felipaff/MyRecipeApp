//
//  FirebaseManager.swift
//  MyRecipeApp
//
//  Created by Felipe Peña on 24-04-25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class FirebaseManager {
    static let shared = FirebaseManager()
    let auth: Auth
    
    private init() {
        self.auth = Auth.auth()
    }

    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Error en Google Sign-In: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let user = result?.user else {
                print("No se encontró usuario tras el Sign-In.")
                completion(false)
                return
            }
            
            guard let idToken = user.idToken?.tokenString else {
                // Aquí puedes manejar el error, por ejemplo:
                completion(false)
                return
            }
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            self.auth.signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error al autenticar en Firebase: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Inicio de sesión exitoso en Firebase!")
                    completion(true)
                }
            }
        }
    }
}
