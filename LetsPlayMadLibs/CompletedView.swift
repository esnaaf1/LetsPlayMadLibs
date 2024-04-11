//
//  CompletedView.swift
//  LetsPlayMadLibs
//
//  Created by Farshad Esnaashari on 4/9/24.
//

import Foundation
import SwiftUI

// Model a completed MadLib
struct MadLibAnswerResponse: Codable, Hashable {
    let filledOutMadLibId: Int
    let madLibId: Int
    let storyTitle: String
    let timestamp: String
}


// Using the network call method that was shared in the class
//
func fetchAllCompleted(userName: String, completion: @escaping ([MadLibAnswerResponse]?) -> Void){
    if (userName == "") {
        completion(nil)
        return
    }
    
    let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/PostMadLib?username=\(userName)" )!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error fetching all Mad Lib solutions: \(error)")
            completion(nil)
            return
        }

        guard let responseData = data else {
          completion(nil)
          return
        }
        
        let decoder = JSONDecoder()
        do {
            let madlib = try decoder.decode([MadLibAnswerResponse].self, from: responseData)
            completion(madlib)
        } catch {
          print("Error decoding JSON data: \(error)")
        }
    }
    task.resume()
}


// View of all complete
struct CompletedView: View {
    @State var madLibAnswerResponseList: [MadLibAnswerResponse]?
    @State var isError: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let madLibAnswerResponseList {
                NavigationSplitView {
                    List {
                        ForEach(madLibAnswerResponseList, id:\.self) { madLibAnswer in
                            NavigationLink {
                                CompletedDetailView(id: madLibAnswer.filledOutMadLibId,
                                                    title: madLibAnswer.storyTitle)
                            } label: {
                                VStack(alignment: .leading, content: {
                                    Text(madLibAnswer.storyTitle)
                                    Text("\(dateFormatter(dateString: madLibAnswer.timestamp))")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                })
                            }
                    
                        }
                    }
                    .navigationTitle("Completed Mad Libs")
                } detail: {
                    Text("Completed Madlibs")

                }
            } else if isError {
                NavigationSplitView {
                    VStack {
                        Text("Username error")
                    }
                } detail: {
                    Text("Completed Madlibs")
                }
                
            }

        }
        .refreshable {
            fetchCompletedList()
        }
        .task {
            guard madLibAnswerResponseList != nil else {
                fetchCompletedList()
                return
            }
        }
    }
    
    private func dateFormatter(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: dateString)
        
        if var d = date {
            d.addTimeInterval(TimeInterval(-18000))
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: d)
            
        } else {
            return ""
        }
    }
    
    private func fetchCompletedList() {
        fetchAllCompleted(userName: userName, completion: {msg in
            if let message = msg {
                madLibAnswerResponseList = message
                isError = false
            } else {
                madLibAnswerResponseList = nil
                isError = true
            }
            
        })
    }
}

#Preview {
    CompletedView()
}

