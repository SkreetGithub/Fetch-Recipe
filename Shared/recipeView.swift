//
//  recipeView.swift
//  Fetch 3.0
//
//  Created by Demetrius Hollins on 2/25/25.
//

import SwiftUI
import WebKit

struct RecipeView: View {
    var recipe: Recipe // Assuming you have a Recipe model
    @State private var ingredients: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Text(recipe.name)
                .font(.largeTitle)
                .padding()

            // Display video URL
            if let videoURL = recipe.youtube_url {
                Text("Video URL: \(videoURL)")
                    .padding()
            }

            // Display ingredients
            if isLoading {
                ProgressView("Loading ingredients...")
                    .padding()
            } else {
                TextEditor(text: $ingredients)
                    .padding()
                    .border(Color.gray, width: 1)
                    .frame(height: 200) // Set a fixed height for better UI
            }

            Button(action: {
                searchIngredients(for: recipe.name)
            }) {
                Text("Search Ingredients")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            fetchIngredients()
        }
    }

    private func fetchIngredients() {
        // Safely unwrap the source_url
        guard let sourceURL = recipe.source_url else {
            print("Source URL is nil")
            return
        }
        
        guard let url = URL(string: sourceURL) else {
            print("Invalid URL: \(sourceURL)")
            return
        }
        
        isLoading = true
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching ingredients: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            // Assuming the response is a JSON containing the ingredients
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any],
                   let ingredientsList = dictionary["ingredients"] as? String {
                    DispatchQueue.main.async {
                        self.ingredients = ingredientsList
                        self.isLoading = false
                    }
                } else {
                    print("Ingredients not found in the response.")
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
            } catch {
                print("Error parsing ingredients: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
        task.resume()
    }

    private func searchIngredients(for recipeName: String) {
        let urlString = "http://www.recipepuppy.com/api/?q=\(recipeName.replacingOccurrences(of: " ", with: "+"))"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching ingredients: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            // Print raw data for debugging
            let dataString = String(data: data, encoding: .utf8)
            print("Raw data: \(dataString ?? "No data")")
            
            // Parse the JSON response
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dictionary = json as? [String: Any],
                   let results = dictionary["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let ingredientsList = firstResult["ingredients"] as? String {
                    DispatchQueue.main.async {
                        self.ingredients = ingredientsList
                        self.isLoading = false
                    }
                } else {
                    print("Ingredients not found in the response.")
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
            } catch {
                print("Error parsing ingredients: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
        task.resume()
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a sample Recipe for preview
        let sampleRecipe = Recipe(uuid: "1", name: "Sample Recipe", cuisine: "Dessert", photo_url_large: "", photo_url_small: "", youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", source_url: "https://example.com/recipe")
        RecipeView(recipe: sampleRecipe)
    }
}



