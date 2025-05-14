//
//  Recipe.swift
//  MyRecipeApp
//
//  Created by Felipe Peña on 24-04-25.
//

struct Recipe: Identifiable, Codable {
    let id: String
    let title: String
    let ingredients: [String]
    let instructions: String
    let calories: Int?
    let protein: Int?
    let fat: Int?
    let carbs: Int?
}
