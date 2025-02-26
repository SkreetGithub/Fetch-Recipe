//
//  CALView.swift
//  Fetch 3.0
//
//  Created by Demetrius Hollins on 2/25/25.
//

import SwiftUI

struct CALView: View {
    let days = Calendar.current.range(of: .day, in: .month, for: Date())!
    let month = Calendar.current.component(.month, from: Date())
    let year = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            Text("\(month) / \(year)")
                .font(.largeTitle)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    Text("\(day)")
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(10)
                        .padding(5)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

struct CALView_Previews: PreviewProvider {
    static var previews: some View {
        CALView()
    }
}
