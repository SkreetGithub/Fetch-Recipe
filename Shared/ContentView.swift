//
//  ContentView.swift
//  Shared
//
//  Created by Demetrius Hollins on 2/25/25.
//


//import SwiftUI
//import Combine
//
//struct ContentView: View {
//    @State private var isRefreshing = false
//    @State private var recipes: [Recipe] = []
//    @State private var suggestedRecipes: [String] = []
//    @State private var searchText: String = ""
//
//    var body: some View {
//        CustomRefreshViewContent(isRefreshing: $isRefreshing, onRefresh: refreshData) {
//            MainPage(recipes: $recipes)
//        }
//        .onAppear {
//            loadInitialRecipes()
//        }
//    }
//
//    private func refreshData() async {
//        // Simulating a network call
//        try? await Task.sleep(nanoseconds: 2_000_000_000)
//        
//        await MainActor.run {
//            loadRecipes()
//        }
//        
//        print("Refresh complete!")
//    }
//
//    private func loadInitialRecipes() {
//        loadRecipes()
//    }
//
//    private func loadRecipes() {
//        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
//            print("Error: Could not find recipes.json in bundle")
//            return
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
//            recipes = response.recipes
//        } catch {
//            print("Error loading recipes: \(error.localizedDescription)")
//        }
//    }
//    
//    var filteredRecipes: [Recipe] {
//        if searchText.isEmpty {
//            return recipes
//        } else {
//            return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//    
//    private func updateSuggestions() {
//        if searchText.isEmpty {
//            suggestedRecipes = []
//        } else {
//            suggestedRecipes = recipes
//                .map { $0.name }
//                .filter { $0.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
