//
//  ContentView.swift
//  LetsPlayMadLibs
//
//  Created by Farshad Esnaashari on 4/9/24.
//

import SwiftUI

let userName = "esna0005"

struct ContentView: View {
    @State private var angle: Double = 0
    
    var body: some View {
        
        VStack {
            Text("Let's Play Mad Libs!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .rotationEffect(.degrees(angle))
                .animation(.linear(duration: 2), value: angle)
                .onAppear {
                    angle = 360
                }
                .padding()
            NavigationStack {
                List {
                    NavigationLink("View Available Mad Libs") {
                        StoryListView()
                    }.fontWeight(.bold)
                    
                    NavigationLink("View Completed Mad Libs") {
                        CompletedView()
                    }.fontWeight(.bold)
                }
                .navigationTitle("Main Menu")

            }
            
            Text(" username = \(userName)")
                .foregroundStyle(.blue)
        }
        

    }
}

#Preview {
    ContentView()
}
