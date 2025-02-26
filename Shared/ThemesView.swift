//
//  ThemesView.swift
//  Fetch 3.0
//
//  Created by Demetrius Hollins on 2/25/25.
//


import SwiftUI

struct ThemesView: View {
    @Binding var isPresented: Bool
    @Binding var selectedColor: Color

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }

            VStack {
                Text("Choose a Theme")
                    .font(.headline)
                    .padding()

                let colors: [Color] = [
                    .red, .orange, .blue, .purple, .green, .yellow, .pink, .cyan, .gray, .black, .white
                ]

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 60, height: 60)
                            .onTapGesture {
                                selectedColor = color
                                isPresented = false
                            }
                    }
                }
                .padding()

                Button("Close") {
                    isPresented = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .frame(width: 300, height: 400)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}


//struct ThemesView_Previews: PreviewProvider {
//    static var previews: some View {
////        ThemesView()
//    }
//}
