//
//  HomeView.swift
//  MyRecipeApp
//
//  Created by Felipe Peña on 24-04-25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    // Recetas de ejemplo usando tu modelo real
    let sampleRecipes: [Recipe] = [
        Recipe(id: UUID().uuidString, title: "Ensalada César", ingredients: ["Lechuga", "Aderezo César", "Queso Parmesano"], instructions: "Mezclar todo y servir.", calories: 300, protein: 10, fat: 20, carbs: 15),
        Recipe(id: UUID().uuidString, title: "Pasta Bolognesa", ingredients: ["Pasta", "Carne Molida", "Salsa de Tomate"], instructions: "Cocinar y mezclar los ingredientes.", calories: 600, protein: 25, fat: 18, carbs: 75),
        Recipe(id: UUID().uuidString, title: "Pollo Teriyaki", ingredients: ["Pollo", "Salsa Teriyaki"], instructions: "Marinar el pollo y cocinar.", calories: 450, protein: 30, fat: 10, carbs: 35),
        Recipe(id: UUID().uuidString, title: "Smoothie de Frutilla", ingredients: ["Frutillas", "Yogur", "Miel"], instructions: "Licuar todo.", calories: 200, protein: 5, fat: 2, carbs: 30)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 20) {

                // Foto de perfil
                if let photoURL = authViewModel.photoURL , let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                    }
                }

                // Bienvenida
                if let displayName = authViewModel.displayName {
                    Text("Hola, \(displayName)!")
                        .font(.title)
                        .bold()
                } else {
                    Text("Bienvenido!")
                        .font(.title)
                        .bold()
                }

                Text("🍽️ Recetas Disponibles")
                    .font(.headline)
                    .padding(.top)

                // Lista de recetas
                List(sampleRecipes) { recipe in
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        Text(recipe.instructions)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)

                Spacer()

                Button("Cerrar sesión") {
                    authViewModel.logout()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Chef bot")
        }
    }
}
