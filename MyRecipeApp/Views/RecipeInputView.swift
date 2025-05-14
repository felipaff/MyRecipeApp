//  RecipeInputView.swift
//  MyRecipeApp
//  Creado por Felipe Peña el 29-04-25

import SwiftUI
import FirebaseAuth  // para logout()

// MARK: — Modelos de apoyo para parseo de la respuesta AI

/// Estructura exacta que pide el prompt (solo array de objetos).
private struct AIRecipe: Codable {
    let title: String
    let ingredients: [String]
    let instructions: String
    let calories: Int
    let protein: Int
    let fat: Int
    let carbs: Int
}

/// Solo para decodificar la forma de chat.completion de OpenAI
private struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: — Vista principal

struct RecipeInputView: View {
    // — Autenticación
    @EnvironmentObject private var authViewModel: AuthViewModel

    // — Inputs de usuario
    @State private var ingredients = ""
    @State private var calories    = ""
    @State private var protein     = ""
    @State private var fat         = ""
    @State private var carbs       = ""
    @State private var isLoading   = false

    // — Toggles de dieta/condición
    @State private var isDiabetic      = false
    @State private var isHypertensive  = false
    @State private var isCeliac        = false
    @State private var isStomachSick   = false
    @State private var isHungover      = false
    @State private var isVegan         = false
    @State private var isVegetarian    = false
    @State private var isCarnivore     = false
    @State private var isKeto          = false
    @State private var hasCommonSpices = false

    // — Recetas generadas
    @State private var generatedRecipes: [Recipe] = []

    // — API Key
    private var openAIKey: String {
        guard let v = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("Falta OPENAI_API_KEY en Info.plist")
        }
        return v
    }

    var body: some View {
        NavigationView {
            List {
                // Ingredientes
                Section("🧾 Ingredientes") {
                    TextEditor(text: $ingredients)
                        .frame(minHeight: 80, maxHeight: 120)
                }

                // Nutrición
                Section("📊 Nutrición (opcionales)") {
                    HStack { Text("Calorías:");     TextField("500", text: $calories).keyboardType(.numberPad) }
                    HStack { Text("Proteínas:");    TextField("30",  text: $protein).keyboardType(.numberPad) }
                    HStack { Text("Grasas:");       TextField("20",  text: $fat).keyboardType(.numberPad) }
                    HStack { Text("Carbohidratos:");TextField("50",  text: $carbs).keyboardType(.numberPad) }
                }

                // Dieta / Condiciones
                Section("🩺 Salud / Dieta") {
                    Toggle("Diabético",             isOn: $isDiabetic)
                    Toggle("Hipertenso",           isOn: $isHypertensive)
                    Toggle("Celíaco",              isOn: $isCeliac)
                    Toggle("Problemas estómago",   isOn: $isStomachSick)
                    Toggle("Resaca",               isOn: $isHungover)
                    Toggle("Vegano",               isOn: $isVegan)
                    Toggle("Vegetariano",          isOn: $isVegetarian)
                    Toggle("Carnívoro",            isOn: $isCarnivore)
                    Toggle("Cetogénico (keto)",    isOn: $isKeto)
                    Toggle("Especias comunes",     isOn: $hasCommonSpices)
                }

                // Botón Generar
                Section {
                    Button {
                        Task { await generateRecipes() }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("🔍 Generar recetas con IA")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Resultados
                if !generatedRecipes.isEmpty {
                    Section("🍽️ Resultados sugeridos") {
                        ForEach(generatedRecipes) { receta in
                            NavigationLink {
                                RecipeDetailView(
                                    recipe: receta,
                                    goalCalories: Int(calories),
                                    goalProtein:  Int(protein),
                                    goalFat:      Int(fat),
                                    goalCarbs:    Int(carbs)
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(receta.title)
                                        .font(.headline)
                                    Text("\(receta.calories ?? 0) kcal • \(receta.protein ?? 0)g proteína")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Buscar Recetas IA")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar sesión") {
                        authViewModel.logout()
                    }
                }
            }
            .hideKeyboardOnTap()
        }
    }

    // MARK: — Construcción de prompt

    private func buildPrompt() -> String {
        var p = "Genera recetas en español usando los siguientes ingredientes: \(ingredients)."
        if let c = Int(calories),    c > 0 { p += " Aprox. \(c) kcal." }
        if let p2 = Int(protein),    p2 > 0 { p += " Al menos \(p2)g de proteína." }
        if let f  = Int(fat),         f > 0 { p += " Hasta \(f)g de grasa." }
        if let cb = Int(carbs),       cb > 0 { p += " Hasta \(cb)g de carbos." }
        if isDiabetic      { p += " Apta para diabéticos." }
        if isHypertensive  { p += " Baja en sodio." }
        if isCeliac        { p += " Libre de gluten." }
        if isStomachSick   { p += " Suave estómago." }
        if isHungover      { p += " Ideal para resaca." }
        if isVegan         { p += " Debe ser vegana." }
        if isVegetarian    { p += " Debe ser vegetariana." }
        if isCarnivore     { p += " Apta carnívoros." }
        if isKeto          { p += " Dieta cetogénica." }
        if hasCommonSpices { p += " Asume especias comunes." }
        p += " **Devuélveme solo un JSON válido** con un array de objetos: title, ingredients, instructions, calories, protein, fat, carbs."
        return p
    }

    // MARK: — Llamada API y parseo

    private func generateRecipes() async {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        let prompt = buildPrompt()

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = [
            "Authorization": "Bearer \(openAIKey)",
            "Content-Type":  "application/json"
        ]
        let body: [String:Any] = [
            "model":"gpt-3.5-turbo",
            "messages":[
                ["role":"system","content":"Eres un chef experto en nutrición."],
                ["role":"user",  "content":prompt]
            ],
            "temperature":0.7
        ]

        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: req)
            let raw = String(decoding: data, as: UTF8.self)
            print("📥 JSON crudo:\n\(raw)")
            let api = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            let content = api.choices.first?.message.content ?? ""
            let recetas = parseRecipes(from: content)
            await MainActor.run { generatedRecipes = recetas }
        } catch {
            print("❌ Error red/parseo:", error)
        }
    }

    private func parseRecipes(from text: String) -> [Recipe] {
        let clean = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```",     with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = clean.data(using: .utf8) else { return [] }
        do {
            let aiList = try JSONDecoder().decode([AIRecipe].self, from: data)
            return aiList.map { ai in
                Recipe(
                    id: UUID().uuidString,
                    title: ai.title,
                    ingredients: ai.ingredients,
                    instructions: ai.instructions,
                    calories: ai.calories,
                    protein: ai.protein,
                    fat: ai.fat,
                    carbs: ai.carbs
                )
            }
        } catch {
            print("❌ Decoding JSON:", error)
            return []
        }
    }
}

// MARK: — Ocultar teclado al tocar fuera

extension View {
    func hideKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}
