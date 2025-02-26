//
//  recipeVideo.swift
//  Fetch 3.0
//
//  Created by Demetrius Hollins on 2/25/25.
//

import SwiftUI
import WebKit

struct RecipeVideo: View {
    let videoURL: String
    let sourceURL: String
    @State private var ingredients: String = "Loading ingredients..."
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                YouTubeView(videoURL: videoURL)
                    .frame(height: 300)
                    .edgesIgnoringSafeArea(.top)

                Text(videoURL)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ingredients")
                            .font(.headline)
                            .padding(.top)

                        if isLoading {
                            ProgressView("Loading ingredients...")
                        } else {
                            Text(ingredients)
                                .padding()
                        }

                        if let url = URL(string: sourceURL) {
                            Link("View Full Recipe", destination: url)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recipe Video")
            .onAppear {
                fetchIngredients()
            }
        }
    }

    private func fetchIngredients() {
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
            guard let data = data else { return }

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
}

struct YouTubeView: UIViewRepresentable {
    let videoURL: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: videoURL) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: YouTubeView
        
        init(_ parent: YouTubeView) {
            self.parent = parent
        }
    }
}

struct RecipeVideo_Previews: PreviewProvider {
    static var previews: some View {
        RecipeVideo(videoURL: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", sourceURL: "https://example.com/recipe")
    }
}


