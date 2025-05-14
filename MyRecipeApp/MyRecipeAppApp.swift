//
//  MyRecipeAppApp.swift
//
import SwiftUI
import Firebase

@main
struct MyRecipeAppApp: App {
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if authViewModel.isLoggedIn {
                    RecipeInputView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
        }
    }
}
