//
//  StoryDetailView.swift
//  LetsPlayMadLibs
//
//  Created by Farshad Esnaashari on 4/7/24.
//

import Foundation
import SwiftUI

import Foundation

// Create the required data structures

// Model a Mad Lib story
struct MadLib: Codable {
    let id: Int
    let storyTitle: String
    let story: String
    let questions: [Questions]
    
    func createAnswerForm(answerList: [String], username: String) -> FilledOutMadLib {
        var answers: [Answer] = []
        for question in questions {
            answers.append(Answer(questionId: question.id, answerValue: answerList[question.position]))
        }
        let date = Date()
        let localISOFormatter = ISO8601DateFormatter()
        localISOFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        
        let dateString = localISOFormatter.string(from: date)
        
        return FilledOutMadLib(madLibId: self.id, username: username, timestamp: dateString, answers: answers)
    }
}

// Model questions related to a Mad Lib story
struct Questions: Codable, Identifiable {
    let id: Int
    let position: Int
    let description: String
}

// Model a filled-out Mad Lib

struct FilledOutMadLib: Codable {
    let madLibId: Int
    var username: String
    var timestamp: String
    var answers: [Answer]
}

// Model answers for a filled-out Mad Lib
struct Answer: Codable {
    var questionId: Int
    var answerValue: String
}

// Using the network call method that was shared in the class
func fetchAStory(id: Int, completion: @escaping (MadLib?) -> Void){
    let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/MadLib/\(id)" )!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error fetching the Mad Lib with id: \(id): \(error)")
            completion(nil)
            return
        }

        guard let responseData = data else {
          completion(nil)
          return
        }
        
        let decoder = JSONDecoder()
        do {
          let madlib = try decoder.decode(MadLib.self, from: responseData)
            completion(madlib)

        } catch {
          print("Error decoding JSON data: \(error)")
        }
    }
    task.resume()
}

// Create a function for posting answers for blanks in a Mad Lib story
func postFilledOutMadLib(body: FilledOutMadLib, completion: @escaping (String?) -> Void){
    let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/PostMadLib" )!
    let data = try! JSONEncoder().encode(body)

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("POST Error: \(error)")
            return
        }

        guard let responseData = data else {
          return
        }
        
        let responseString = String(data: responseData, encoding: .utf8)
        completion(responseString)
        
    }
    
    task.resume()
}

// Create a vew for the Madlib Story Details

struct StoryDetailView: View {
    let id: Int
    @State var madLib: MadLib?
    @State var answers: [String] = []
    @State var canSubmit: Bool = false
    @State var responseString: String?
    @State var fetching: Bool = false

    var body: some View {
        VStack {
            Form {
                Section() {
                    if let madLib, !answers.isEmpty {
                        List {
                            ForEach(madLib.questions) { question in
                                HStack {
                                    Text("\(question.description):").bold()
                                    TextField("\(question.description)", text: $answers[question.position])
                                        .disabled(responseString != nil)
                                        .autocapitalization(.none)
                                }
                            }
                        }
                        .navigationBarTitle(madLib.storyTitle)

                    }
                } header: {
                    Text("Enter a value for the following blanks: ")
                } footer: {
                    VStack(alignment: .center) {
                        Spacer()
                        Button("Submit") {
                            Task {
                                fetching = true
                                await submitForm()
                            }
                        }
                        .disabled(!checkSubmitEnabled())
                            
                    }
                }
                
                if let responseString {
                    Section() {
                        Text(responseString)
                        
                    } header: {
                        HStack(alignment: .center) {
                            Text("Completed Story: ")
                        }
                    }

                }
            }

        }
        .task {
            guard madLib != nil else {
                fetchAStory(id: id, completion: {msg in
                    madLib = msg
                    if let madLib {
                        answers = [String](repeating: "", count: madLib.questions.count)
                    }
                })
                return
            }
        }
    }
    
    func checkSubmitEnabled() -> Bool {
        if (responseString != nil) {
            return false
        }
        
        for answer in answers {
            if answer == "" {
                return false
            }
        }
        return true
    }
    
    func resetForm() {
        if let madLib {
            answers = [String](repeating: "", count: madLib.questions.count)
            canSubmit = false
            responseString = nil
            fetching = false
        }
    }
    
    func submitForm() async {
        if let madLib {
            let answerForm = madLib.createAnswerForm(answerList: answers, username: "esna0004")
            postFilledOutMadLib(body: answerForm, completion: {msg in
                responseString = msg
                fetching = false
            })
        }
    }
}

#Preview {
    StoryDetailView(id: 1)
}


