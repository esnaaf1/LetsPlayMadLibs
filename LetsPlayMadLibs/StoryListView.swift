//
//  StoryListView.swift
//  LetsPlayMadLibs
//
//  Created by Farshad Esnaashari on 4/7/24.
//

import Foundation
import SwiftUI

// Create a data structure for modeling a Mad Lib story
struct Story: Identifiable, Decodable {
    let id: Int
    let storyTitle: String
}

// Using ViewModel method with ObservableObject to get a list of Mad Lib
// Stories
class StoryViewModel: ObservableObject {
    @Published var stories = [Story]()

    func fetchStories(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Error fetching Mad Lib Stories \(error)")
                return
            }
            
            guard let data = data else { return }

            let decoder = JSONDecoder()
            if let stories = try? decoder.decode([Story].self, from: data) {
                DispatchQueue.main.async {
                    self.stories = stories
                }
            }
        }.resume()
    }
}


// Create a view of all available Mad Lib Stories
struct StoryListView: View {
    @ObservedObject var viewModel = StoryViewModel()

    var body: some View {
        VStack {
            NavigationStack {
                List (viewModel.stories) { story in
                    NavigationLink("\(story.storyTitle)") {
                        StoryDetailView(id: story.id)
                    }
                                    
                }
                .onAppear {
                    viewModel.fetchStories(from: "https://seng5199madlib.azurewebsites.net/api/MadLib")
                }
                .navigationTitle("Mad Libs")

            }

        }

    }
}

#Preview {
    
    StoryListView()
}


