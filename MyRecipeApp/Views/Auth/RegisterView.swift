//
//  RegisterView.swift
//  MyRecipeApp
//
//  Created by Felipe Peña on 24-04-25.
//

// Views/Auth/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var authVM = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Crear Cuenta").font(.title)

            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Contraseña", text: $password).textFieldStyle(.roundedBorder)
            SecureField("Confirmar contraseña", text: $confirmPassword).textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error).foregroundColor(.red).font(.footnote)
            }

            Button("Registrarse") {
                guard password == confirmPassword else {
                    errorMessage = "Las contraseñas no coinciden"
                    return
                }

                AuthService.shared.register(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            dismiss()
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Ya tengo cuenta") {
                dismiss()
            }.font(.footnote)

            Spacer()
        }
        .padding()
    }
}
