//
//  StoryListView.swift
//  LetsPlayMadLibs
//
//  Created by Farshad Esnaashari on 4/7/24.
//

import Foundation
import SwiftUI
struct Story: Identifiable, Decodable {
    let id: Int
    let storyTitle: String
}

// Trying out the View Model design pattern for the List of Stories
class StoryViewModel: ObservableObject {
    @Published var stories = [Story]()

    func fetchStories(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { (data, _, _) in
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


// Create a view of the Mad Lib Stories
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


