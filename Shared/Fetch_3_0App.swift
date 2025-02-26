//
//  Fetch_3_0App.swift
//  Shared
//
//  Created by Demetrius Hollins on 2/25/25.
//

import SwiftUI

@main
struct Fetch_3_0App: App {
    @State private var recipes: [Recipe] = []

    var body: some Scene {
        WindowGroup {
            MainPage(recipes: $recipes)
                .onAppear {
                    loadInitialRecipes()
                }
        }
    }

    private func loadInitialRecipes() {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            print("Error: Could not find recipes.json in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
            recipes = response.recipes
        } catch {
            print("Error loading recipes: \(error.localizedDescription)")
        }
    }
}

