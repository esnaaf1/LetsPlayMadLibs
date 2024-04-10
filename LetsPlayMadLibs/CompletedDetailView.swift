//
//  CompletedDetailView.swift
//  LetsPlayMadLibs
//
//  Created by Farshad Esnaashari on 4/9/24.
//

import Foundation
import SwiftUI


// Using network call method data was shared in the class
func fetchACompleted(id: Int, completion: @escaping (String?) -> Void){
    let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/PostMadLib/\(id)" )!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error fetching Mad Lib with id \(id): \(error)")
            completion(nil)
            return
        }

        guard let responseData = data else {
          completion(nil)
          return
        }
        
        let responseString = String(data: responseData, encoding: .utf8)
        completion(responseString)
    }
    task.resume()
}

// Create a view for a completed Mad Lib
struct CompletedDetailView: View {
    let id: Int
    let title: String
    @State var answer: String?

    var body: some View {
        VStack {
            if let answer {
                Form {
                    Section() {
                        Text(answer)
                    }
                }
                .navigationTitle(title)
            }
        }
        .task {
            guard answer != nil else {
                fetchACompleted(id: id, completion: {msg in
                    answer = msg
                })
                return
            }
        }
    }
}

#Preview {
    CompletedDetailView(id: 16, title: "Madlib Answer")
}
