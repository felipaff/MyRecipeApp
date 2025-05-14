//  RecipeDetailView.swift
//  Created by Felipe Peña on 24-04-25.
//  MyRecipeApp

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    let goalCalories: Int?
    let goalProtein: Int?
    let goalFat: Int?
    let goalCarbs: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.title)
                    .font(.title).bold()

                if !recipe.ingredients.isEmpty {
                    Text("🧂 Ingredientes:")
                        .font(.headline)
                    ForEach(recipe.ingredients, id: \.self) { item in
                        Text("• \(item)")
                    }
                }

                Text("📝 Instrucciones:")
                    .font(.headline)
                Text(recipe.instructions)
                    .fixedSize(horizontal: false, vertical: true)

                if let cal = recipe.calories,
                   let prot = recipe.protein,
                   let fat = recipe.fat,
                   let carb = recipe.carbs {
                    Text("🔢 Información nutricional:")
                        .font(.headline)
                    Text("Calorías: \(cal) kcal")
                    Text("Proteínas: \(prot) g")
                    Text("Grasas: \(fat) g")
                    Text("Carbohidratos: \(carb) g")

                    if let gCal = goalCalories {
                        Text("📊 Te faltan \(max(0, gCal - cal)) kcal")
                            .foregroundColor(.orange)
                    }
                    if let gProt = goalProtein {
                        Text("📊 Proteínas restantes: \(max(0, gProt - prot)) g")
                            .foregroundColor(.orange)
                    }
                    if let gFat = goalFat {
                        Text("📊 Grasas restantes: \(max(0, gFat - fat)) g")
                            .foregroundColor(.orange)
                    }
                    if let gCarb = goalCarbs {
                        Text("📊 Carbohidratos restantes: \(max(0, gCarb - carb)) g")
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detalle Receta")
    }
}
