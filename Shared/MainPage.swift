//
//  MainPage.swift
//  Fetch 3.0
//
//  Created by Demetrius Hollins on 2/25/25.
//

import SwiftUI
import Combine
import WebKit

struct MainPage: View {
    @Binding var recipes: [Recipe]
    @State private var selectedVideo: String? = nil
    @State private var showVideo = false
    @State private var searchText: String = ""
    @State private var isToggled = false
    @State private var isActive = false
    @State private var isHidden = false
    @State private var suggestedRecipes: [String] = []
    @State private var showThemeOverlay = false
    @State private var selectedThemeColor: Color = .blue // Default theme color
    @State private var showCALView = false
    @State private var isRefreshing = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Dessert Recipes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    Spacer()

                    // Menu Button
                    Menu {
                        Button("Choose Theme") { showThemeOverlay.toggle() }
                        Button("Open CALView") { showCALView.toggle() }
                    } label: {
                        SmoothIcanAnimation(isActive: $isActive)
                            .frame(width: 100, height: 100)
                            .padding()
                    }
                }
                .padding(.horizontal)

                SearchBar(text: $searchText, suggestions: $suggestedRecipes, updateSuggestions: updateSuggestions)
                    .padding()

                // CustomRefreshViewContent now hidden behind the SearchBar
                CustomRefreshViewContent(isRefreshing: $isRefreshing, onRefresh: refreshData) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                        ForEach(filteredRecipes) { recipe in
                            RecipeCard(recipe: recipe) {
                                if let youtubeURL = recipe.youtube_url {
                                    selectedVideo = youtubeURL
                                    showVideo = true
                                }
                            }
                            .frame(width: 150, height: 150)
                        }
                    }
                    .padding(.top, 80) // Added padding above RecipeCards
                }
                .padding(.bottom, 10) // Adjusted to ensure it is behind the SearchBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                withAnimation {
                    isToggled.toggle()
                    isActive.toggle()
                    isHidden.toggle()
                }
            }
            .background(selectedThemeColor.edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarColor(UIColor(selectedThemeColor))
        .sheet(isPresented: $showVideo) {
            if let videoURL = selectedVideo,
               let selectedRecipe = filteredRecipes.first(where: { $0.youtube_url == videoURL }) {
                RecipeVideo(videoURL: videoURL, sourceURL: selectedRecipe.source_url ?? "")
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .overlay(
            Group {
                if showThemeOverlay {
                    ThemesView(isPresented: $showThemeOverlay, selectedColor: $selectedThemeColor)
                        .transition(.opacity)
                }
                if showCALView {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                    
                    CALView()
                        .frame(width: 300, height: 400)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                        .transition(.scale)
                        .onTapGesture { showCALView.toggle() }
                }
            }
        )
        .onChange(of: selectedThemeColor) { newColor in
            UINavigationBar.appearance().barTintColor = UIColor(newColor)
        }
        .accentColor(selectedThemeColor)
    }

    private func refreshData() async {
        // Simulating a network call
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            loadRecipes()
        }
        isRefreshing = false
        print("Refresh complete!")
    }

    private func loadRecipes() {
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

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        } else {
            return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func updateSuggestions() {
        if searchText.isEmpty {
            suggestedRecipes = []
        } else {
            suggestedRecipes = recipes
                .map { $0.name }
                .filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// Define the structure for a Recipe.
struct Recipe: Identifiable, Codable {
    let uuid: String
    let name: String
    let cuisine: String
    let photo_url_large: String
    let photo_url_small: String
    let youtube_url: String?
    let source_url: String?

    var id: String { uuid } // Identifiable conformance

    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case cuisine
        case photo_url_large
        case photo_url_small
        case youtube_url
        case source_url
    }
}

// Define the response model that holds a list of recipes.
struct RecipeResponse: Codable {
    let recipes: [Recipe]
}

struct RecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.photo_url_large)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            } placeholder: {
                ProgressView()
                    .frame(height: 200)
            }
            .onTapGesture {
                onTap()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var suggestions: [String]
    var updateSuggestions: () -> Void
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .trailing) {
                    TextField("Search recipes...", text: $text)
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .focused($isInputFocused)
                        .onChange(of: text) { _ in
                            updateSuggestions()
                        }

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.trailing, 20)
                }
            }

            if !suggestions.isEmpty {
                List(suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .onTapGesture {
                            text = suggestion
                            suggestions = []
                        }
                }
                .frame(height: 150)
            }
        }
    }
}

struct SmoothIcanAnimation: View {
    @Binding var isActive: Bool // Binding to control the active state

    var body: some View {
        VStack(spacing: 8) { // Spacing between lines
            Line()
                .rotationEffect(.degrees(isActive ? 45 : 0), anchor: .center) // Rotate first line
                .offset(y: isActive ? 10 : 0) // Move down when active
            
            Line()
                .opacity(isActive ? 0 : 1) // Hide middle line when active
            
            Line()
                .rotationEffect(.degrees(isActive ? -45 : 0), anchor: .center) // Rotate third line
                .offset(y: isActive ? -10 : 0) // Move up when active
        }
        .frame(width: 64, height: 64) // Set frame size
        .contentShape(Rectangle()) // Make the entire area tappable
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                isActive.toggle() // Toggle the active state with animation
            }
        }
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.black) // Set line color
            .frame(width: 32, height: 2) // Set line dimensions
    }
}

// Custom modifier to change navigation bar color
struct NavigationBarColor: ViewModifier {
    var color: UIColor

    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBar.appearance()
                appearance.barTintColor = color
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Change title color if needed
            }
            .onDisappear {
                let appearance = UINavigationBar.appearance()
                appearance.barTintColor = nil // Reset to default when view disappears
            }
    }
}

extension View {
    func navigationBarColor(_ color: UIColor) -> some View {
        self.modifier(NavigationBarColor(color: color))
    }
}

// NavigationConfigurator to change navigation bar appearance
struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let navigationController = uiViewController.navigationController {
            configure(navigationController)
        }
    }
}

// Preview provider for SwiftUI previews
struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(recipes: .constant([Recipe(uuid: "1", name: "Recipe 1", cuisine: "Cuisine 1", photo_url_large: "https://example.com/large.jpg", photo_url_small: "https://example.com/small.jpg", youtube_url: "https://example.com/video.mp4", source_url: "https://example.com"), Recipe(uuid: "2", name: "Recipe 2", cuisine: "Cuisine 2", photo_url_large: "https://example.com/large2.jpg", photo_url_small: "https://example.com/small2.jpg", youtube_url: nil, source_url: nil)]))
    }
}

