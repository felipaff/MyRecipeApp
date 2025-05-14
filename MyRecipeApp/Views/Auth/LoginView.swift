import SwiftUI
import GoogleSignIn
import Firebase

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Iniciar Sesión")
                .font(.title)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Entrar con Email") {
                authViewModel.login(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)

            Button("¿No tienes cuenta? Regístrate aquí") {
                showRegister = true
            }
            .font(.footnote)
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView()
            }

            Button("Iniciar sesión con Google") {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    FirebaseManager.shared.signInWithGoogle(presentingViewController: root) { success in
                        if success {
                            DispatchQueue.main.async {
                                authViewModel.isLoggedIn = true
                            }
                        }
                    }
                }
            }
            .buttonStyle(.bordered)
            .padding(.top)

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $authViewModel.isLoggedIn) {
            RecipeInputView()
                .environmentObject(authViewModel)
        }
    }
}
